/*
   ▄████████    ▄████████    ▄████████  ▄█   ▄████████    ▄████████    ▄████████    ▄████████    ▄████████    ▄████████
  ███    ███   ███    ███   ███    ███ ███  ███    ███   ███    ███   ███    ███   ███    ███   ███    ███   ███    ███
  ███    ███   ███    █▀    ███    ███ ███▌ ███    █▀    ███    ███   ███    ███   ███    ███   ███    ███   ███    █▀
  ███    ███  ▄███▄▄▄      ▄███▄▄▄▄██▀ ███▌ ███          ███    ███  ▄███▄▄▄▄██▀   ███    ███  ▄███▄▄▄▄██▀  ▄███▄▄▄
▀███████████ ▀▀███▀▀▀     ▀▀███▀▀▀▀▀   ███▌ ███        ▀███████████ ▀▀███▀▀▀▀▀   ▀███████████ ▀▀███▀▀▀▀▀   ▀▀███▀▀▀
  ███    ███   ███        ▀███████████ ███  ███    █▄    ███    ███ ▀███████████   ███    ███ ▀███████████   ███    █▄
  ███    ███   ███          ███    ███ ███  ███    ███   ███    ███   ███    ███   ███    ███   ███    ███   ███    ███
  ███    █▀    ███          ███    ███ █▀   ████████▀    ███    █▀    ███    ███   ███    █▀    ███    ███   ██████████
                            ███    ███                                ███    ███                ███    ███

 * @title AfricaRare Marketplace Contract
 * @author Africarare (@africarare)
 * @dev Smart contract for Africarare's Marketplace
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IAfricarareNFTFactory.sol";
import "./interfaces/IAfricarareNFT.sol";
import "./errors/errors.sol";
import "./structures/structs.sol";
import {MarketplaceEvents} from "./events/events.sol";

/*
    @dev: Africarare NFT Marketplace
    @dev: List NFT,
    @dev: Buy NFT,
    @dev: Offer NFT,
    @dev: Accept offer,
    @dev: Create auction,
    @dev: Bid place,
    @dev: Support Royalty,
    @TODO: Support ERC1155,
    @TODO: Store assets in storage contract,
    @TODO: Remove require statements for custom errs,
    @TODO: Change fee logic to work in percentages 0-100,
    @TODO: end to end unit test
    @TODO: clean up offer, list logic
    @TODO: add timestamps to structs and events
    @TODO: use safe 1155, 721 interfaces like safe erc20?
*/

contract AfricarareNFTMarketplace is
    ERC721Holder,
    ERC1155Holder,
    Ownable,
    ReentrancyGuard,
    MarketplaceEvents
{
    using SafeERC20 for IERC20;
    IAfricarareNFTFactory private immutable africarareNFTFactory;

    uint256 private platformFee;
    address private feeRecipient;

    mapping(address => bool) private payableToken;
    address[] private tokens;

    // @dev: nft => tokenId => list struct
    mapping(address => mapping(uint256 => ListNFT)) private listNfts;

    // @dev: nft => tokenId => offerer address => offer struct
    mapping(address => mapping(uint256 => mapping(address => OfferNFT)))
        private offerNfts;

    // @dev: nft => tokenId => auction struct
    mapping(address => mapping(uint256 => AuctionNFT)) private auctionNfts;

    // @dev: auction index => bidding counts => bidder address => bid price
    mapping(uint256 => mapping(uint256 => mapping(address => uint256)))
        private bidPrices;

    constructor(
        uint256 _platformFee,
        address _feeRecipient,
        IAfricarareNFTFactory _africarareNFTFactory
    ) {
        if (_platformFee > 10000)
            revert PlatformFeeExceedLimit(_platformFee, 10000);
        platformFee = _platformFee;
        feeRecipient = _feeRecipient;
        africarareNFTFactory = _africarareNFTFactory;
    }

    modifier isAfricarareNFT(address _nftAddress) {
        require(
            africarareNFTFactory.isAfricarareNFT(_nftAddress),
            "not Africarare NFT"
        );
        _;
    }

    //@dev: This is a gas optimisation trick reusing function instead of require in modifier
    function _isListedNFT(address _nftAddress, uint256 _tokenId) internal view {
        if (listNfts[_nftAddress][_tokenId].seller == address(0)) {
            revert SellerIsZeroAddress(_nftAddress, _tokenId);
        }
        if (listNfts[_nftAddress][_tokenId].sold) {
            revert ItemIsSold(_nftAddress, _tokenId);
        }
    }

    modifier isListedNFT(address _nftAddress, uint256 _tokenId) {
        _isListedNFT(_nftAddress, _tokenId);
        _;
    }

    modifier isNotListedNFT(address _nftAddress, uint256 _tokenId) {
        ListNFT memory listedNFT = listNfts[_nftAddress][_tokenId];
        require(
            listedNFT.seller == address(0) || listedNFT.sold,
            "already listed"
        );
        _;
    }

    modifier isAuction(address _nftAddress, uint256 _tokenId) {
        AuctionNFT memory auction = auctionNfts[_nftAddress][_tokenId];
        require(
            auction.nft != address(0) && !auction.success,
            "auction already created"
        );
        _;
    }

    modifier isNotAuction(address _nftAddress, uint256 _tokenId) {
        AuctionNFT memory auction = auctionNfts[_nftAddress][_tokenId];
        require(
            auction.nft == address(0) || auction.success,
            "auction already created"
        );
        _;
    }

    modifier isOfferedNFT(
        address _nftAddress,
        uint256 _tokenId,
        address _offerer
    ) {
        OfferNFT memory offer = offerNfts[_nftAddress][_tokenId][_offerer];
        require(
            offer.offerPrice > 0 && offer.offerer != address(0),
            "not offered nft"
        );
        _;
    }

    modifier isPayableToken(address _payToken) {
        require(
            _payToken != address(0) && payableToken[_payToken],
            "invalid pay token"
        );
        _;
    }


    //@notice: List NFT
    function listNft(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken,
        uint256 _price
    ) external isAfricarareNFT(_nftAddress) isPayableToken(_payToken) {
        IERC721 nft = IERC721(_nftAddress);
        require(nft.ownerOf(_tokenId) == msg.sender, "not nft owner");
        nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        listNfts[_nftAddress][_tokenId] = ListNFT({
            nft: _nftAddress,
            tokenId: _tokenId,
            seller: msg.sender,
            payToken: _payToken,
            price: _price,
            sold: false
        });

        emit ListedNFT(_nftAddress, _tokenId, _payToken, _price, msg.sender);
    }

    //@notice: Cancel listed NFT
    function cancelListedNFT(address _nftAddress, uint256 _tokenId)
        external
        isListedNFT(_nftAddress, _tokenId)
    {
        ListNFT memory listedNFT = listNfts[_nftAddress][_tokenId];
        require(listedNFT.seller == msg.sender, "not listed owner");
        delete listNfts[_nftAddress][_tokenId];
        IERC721(_nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );
    }

    // @notice: Buy listed NFT
    function buyNFT(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken,
        uint256 _price
    ) external isListedNFT(_nftAddress, _tokenId) {
        ListNFT storage listedNft = listNfts[_nftAddress][_tokenId];
        require(
            _payToken != address(0) && _payToken == listedNft.payToken,
            "invalid pay token"
        );
        require(!listedNft.sold, "nft already sold");
        require(_price >= listedNft.price, "invalid price");

        listedNft.sold = true;

        uint256 totalPrice = _price;
        IAfricarareNFT nft = IAfricarareNFT(listedNft.nft);
        address royaltyRecipient = nft.getRoyaltyRecipient();
        uint256 royaltyFee = nft.getRoyaltyFee();

        if (royaltyFee > 0) {
            uint256 royaltyTotal = calculateRoyalty(royaltyFee, _price);

            // Transfer royalty fee to collection owner
            IERC20(listedNft.payToken).safeTransferFrom(
                msg.sender,
                royaltyRecipient,
                royaltyTotal
            );
            totalPrice -= royaltyTotal;
        }

        // Calculate & Transfer platform fee
        uint256 platformFeeTotal = calculatePlatformFee(_price);
        IERC20(listedNft.payToken).safeTransferFrom(
            msg.sender,
            feeRecipient,
            platformFeeTotal
        );

        // Transfer to nft owner
        IERC20(listedNft.payToken).safeTransferFrom(
            msg.sender,
            listedNft.seller,
            totalPrice - platformFeeTotal
        );

        // Transfer NFT to buyer
        IERC721(listedNft.nft).safeTransferFrom(
            address(this),
            msg.sender,
            listedNft.tokenId
        );

        emit BoughtNFT(
            listedNft.nft,
            listedNft.tokenId,
            listedNft.payToken,
            _price,
            listedNft.seller,
            msg.sender
        );
    }

    function offerNFT(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken,
        uint256 _offerPrice
    ) external isListedNFT(_nftAddress, _tokenId) {
        require(_offerPrice > 0, "price can not 0");

        ListNFT memory nft = listNfts[_nftAddress][_tokenId];
        IERC20(nft.payToken).safeTransferFrom(
            msg.sender,
            address(this),
            _offerPrice
        );

        offerNfts[_nftAddress][_tokenId][msg.sender] = OfferNFT({
            nft: nft.nft,
            tokenId: nft.tokenId,
            offerer: msg.sender,
            payToken: _payToken,
            offerPrice: _offerPrice,
            accepted: false
        });

        emit OfferedNFT(
            nft.nft,
            nft.tokenId,
            nft.payToken,
            _offerPrice,
            msg.sender
        );
    }

    // @notice Offerer cancel offering
    function cancelOfferNFT(address _nftAddress, uint256 _tokenId)
        external
        isOfferedNFT(_nftAddress, _tokenId, msg.sender)
    {
        OfferNFT memory offer = offerNfts[_nftAddress][_tokenId][msg.sender];
        if (offer.offerer != msg.sender)
            revert NotOfferer(offer.offerer, msg.sender);
        // require(offer.offerer == msg.sender, "not offerer");
        require(!offer.accepted, "offer already accepted");
        delete offerNfts[_nftAddress][_tokenId][msg.sender];
        IERC20(offer.payToken).safeTransfer(offer.offerer, offer.offerPrice);
        emit CanceledOfferedNFT(
            offer.nft,
            offer.tokenId,
            offer.payToken,
            offer.offerPrice,
            msg.sender
        );
    }

    // @notice listed NFT owner accept offering
    function acceptOfferNFT(
        address _nftAddress,
        uint256 _tokenId,
        address _offerer
    )
        external
        isOfferedNFT(_nftAddress, _tokenId, _offerer)
        isListedNFT(_nftAddress, _tokenId)
    {
        require(
            listNfts[_nftAddress][_tokenId].seller == msg.sender,
            "not listed owner"
        );
        OfferNFT storage offer = offerNfts[_nftAddress][_tokenId][_offerer];
        ListNFT storage list = listNfts[offer.nft][offer.tokenId];
        require(!list.sold, "already sold");
        require(!offer.accepted, "offer already accepted");

        list.sold = true;
        offer.accepted = true;

        uint256 offerPrice = offer.offerPrice;

        IAfricarareNFT nft = IAfricarareNFT(offer.nft);
        address royaltyRecipient = nft.getRoyaltyRecipient();
        uint256 royaltyFee = nft.getRoyaltyFee();

        IERC20 payToken = IERC20(offer.payToken);

        // Transfer royalty fee to collection owner
        uint256 royaltyTotal = calculateRoyalty(royaltyFee, offerPrice);
        if (royaltyTotal > 0) {
            payToken.safeTransfer(royaltyRecipient, royaltyTotal);
        }

        // Calculate & Transfer platform fee
        uint256 platformFeeTotal = calculatePlatformFee(offerPrice);
        if (platformFeeTotal > 0) {
            payToken.safeTransfer(feeRecipient, platformFeeTotal);
        }

        // Transfer to seller
        payToken.safeTransfer(
            list.seller,
            offerPrice - platformFeeTotal - royaltyTotal
        );

        // Transfer NFT to offerer
        IERC721(list.nft).safeTransferFrom(
            address(this),
            offer.offerer,
            list.tokenId
        );

        emit AcceptedNFT(
            offer.nft,
            offer.tokenId,
            offer.payToken,
            offer.offerPrice,
            offer.offerer,
            list.seller
        );
    }

    // @notice Create auction
    function createAuction(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken,
        uint256 _price,
        uint256 _minBid,
        uint256 _startTime,
        uint256 _endTime
    ) external isPayableToken(_payToken) isNotAuction(_nftAddress, _tokenId) {
        IERC721 nft = IERC721(_nftAddress);
        require(nft.ownerOf(_tokenId) == msg.sender, "not nft owner");
        require(_endTime > _startTime, "invalid end time");

        auctionNfts[_nftAddress][_tokenId] = AuctionNFT({
            nft: _nftAddress,
            tokenId: _tokenId,
            creator: msg.sender,
            payToken: _payToken,
            initialPrice: _price,
            minBid: _minBid,
            startTime: _startTime,
            endTime: _endTime,
            lastBidder: address(0),
            highestBid: _price,
            winner: address(0),
            success: false
        });

        nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        emit CreatedAuction(
            _nftAddress,
            _tokenId,
            _payToken,
            _price,
            _minBid,
            _startTime,
            _endTime,
            msg.sender
        );
    }

    // @notice Cancel auction
    function cancelAuction(address _nftAddress, uint256 _tokenId)
        external
        isAuction(_nftAddress, _tokenId)
    {
        AuctionNFT memory auction = auctionNfts[_nftAddress][_tokenId];
        require(auction.creator == msg.sender, "not auction creator");
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp < auction.startTime, "auction already started");
        require(auction.lastBidder == address(0), "already have bidder");

        IERC721 nft = IERC721(_nftAddress);
        delete auctionNfts[_nftAddress][_tokenId];
        nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        emit CancelledAuction(
            _nftAddress,
            _tokenId,
            // solhint-disable-next-line not-rely-on-time
            block.timestamp,
            msg.sender
        );
    }

    // @notice Bid place auction
    function bidPlace(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _bidPrice
    ) external isAuction(_nftAddress, _tokenId) {
        require(
            // solhint-disable-next-line not-rely-on-time
            block.timestamp >= auctionNfts[_nftAddress][_tokenId].startTime,
            "auction not start"
        );
        require(
            // solhint-disable-next-line not-rely-on-time
            block.timestamp <= auctionNfts[_nftAddress][_tokenId].endTime,
            "auction ended"
        );
        require(
            _bidPrice >=
                auctionNfts[_nftAddress][_tokenId].highestBid +
                    auctionNfts[_nftAddress][_tokenId].minBid,
            "less than min bid price"
        );

        AuctionNFT storage auction = auctionNfts[_nftAddress][_tokenId];
        IERC20 payToken = IERC20(auction.payToken);
        // Set new highest bid price
        auction.lastBidder = msg.sender;
        auction.highestBid = _bidPrice;
        payToken.safeTransferFrom(msg.sender, address(this), _bidPrice);

        if (auction.lastBidder != address(0)) {
            address lastBidder = auction.lastBidder;
            uint256 lastBidPrice = auction.highestBid;

            // Transfer back to last bidder
            payToken.safeTransfer(lastBidder, lastBidPrice);
        }

        emit PlacedBid(
            _nftAddress,
            _tokenId,
            auction.payToken,
            _bidPrice,
            msg.sender
        );
    }

    // @notice Result auction, can call by auction creator, highest bidder, or marketplace owner only!
    function resultAuction(address _nftAddress, uint256 _tokenId) external {
        require(
            !auctionNfts[_nftAddress][_tokenId].success,
            "already resulted"
        );
        require(
            msg.sender == owner() ||
                msg.sender == auctionNfts[_nftAddress][_tokenId].creator ||
                msg.sender == auctionNfts[_nftAddress][_tokenId].lastBidder,
            "not creator, winner, or owner"
        );
        require(
            // solhint-disable-next-line not-rely-on-time
            block.timestamp > auctionNfts[_nftAddress][_tokenId].endTime,
            "auction not ended"
        );

        AuctionNFT storage auction = auctionNfts[_nftAddress][_tokenId];
        IERC20 payToken = IERC20(auction.payToken);
        IERC721 nft = IERC721(auction.nft);

        auction.success = true;
        auction.winner = auction.creator;

        IAfricarareNFT africarareNft = IAfricarareNFT(_nftAddress);
        address royaltyRecipient = africarareNft.getRoyaltyRecipient();
        uint256 royaltyFee = africarareNft.getRoyaltyFee();

        uint256 highestBid = auction.highestBid;
        uint256 totalPrice = highestBid;

        if (royaltyFee > 0) {
            uint256 royaltyTotal = calculateRoyalty(royaltyFee, highestBid);
            // Transfer royalty fee to collection owner
            payToken.safeTransfer(royaltyRecipient, royaltyTotal);
            totalPrice -= royaltyTotal;
        }

        // Calculate & Transfer platform fee
        uint256 platformFeeTotal = calculatePlatformFee(highestBid);
        payToken.safeTransfer(feeRecipient, platformFeeTotal);

        // Transfer to auction creator
        payToken.safeTransfer(auction.creator, totalPrice - platformFeeTotal);

        // Transfer NFT to the winner
        nft.safeTransferFrom(
            address(this),
            auction.lastBidder,
            auction.tokenId
        );

        emit ResultedAuction(
            _nftAddress,
            _tokenId,
            auction.creator,
            auction.lastBidder,
            auction.highestBid,
            msg.sender
        );
    }

    function calculatePlatformFee(uint256 _price)
        public
        view
        returns (uint256)
    {
        return (_price * platformFee) / 10000;
    }

    function calculateRoyalty(uint256 _royalty, uint256 _price)
        public
        pure
        returns (uint256)
    {
        return (_price * _royalty) / 10000;
    }

    function getListedNFT(address _nftAddress, uint256 _tokenId)
        public
        view
        returns (ListNFT memory)
    {
        return listNfts[_nftAddress][_tokenId];
    }

    function getPayableTokens() external view returns (address[] memory) {
        return tokens;
    }

    function checkIsPayableToken(address _payableToken)
        external
        view
        returns (bool)
    {
        return payableToken[_payableToken];
    }

    function addPayableToken(address _token) external onlyOwner {
        require(_token != address(0), "invalid token");
        require(!payableToken[_token], "already payable token");
        payableToken[_token] = true;
        tokens.push(_token);
    }

    function updatePlatformFee(uint256 _platformFee) external onlyOwner {
        require(_platformFee <= 10000, "can't more than 10 percent");
        platformFee = _platformFee;
    }

    function changeFeeRecipient(address _feeRecipient) external onlyOwner {
        require(_feeRecipient != address(0), "can't be 0 address");
        feeRecipient = _feeRecipient;
    }


}
