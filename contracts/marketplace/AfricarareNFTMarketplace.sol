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
import "hardhat/console.sol";

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
    @TODO: end to end unit test all custom errors and exceptions
    @TODO: clean up offer, list logic
    @TODO: add timestamps to structs and events
    @TODO: use safe 1155, 721 interfaces like safe erc20?
    @TODO: remove payable tokens as well as add them
    @TODO: test fee logic math is correctly deducting right amounts
    @TODO: remove uint256 for uint, let compiler optimise, or at least try
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

    mapping(address => bool) private payableTokens;
    address[] private paymentTokens;

    //TODO: Move to storage contract
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
        if (_platformFee > 1000)
            revert PlatformFeeExceedLimit(_platformFee, 1000);

        platformFee = _platformFee;

        if (_feeRecipient != address(0)) {
            feeRecipient = _feeRecipient;
        }
        africarareNFTFactory = _africarareNFTFactory;
    }

    function _sufficientBalance(uint256 price, uint256 offer) internal pure {
        if (price > offer) revert InsufficientBalance(price, offer);
    }

    modifier sufficientBalance(uint256 price, uint256 offer) {
        _sufficientBalance(price, offer);
        _;
    }

    function _notZeroAddress(address _address) internal pure {
        if (_address == address(0)) {
            revert AddressIsZero(_address);
        }
    }

    modifier nonZeroAddress(address _address) {
        _notZeroAddress(_address);
        _;
    }

    function _onlyListedNFTOwner(address _nftAddress, uint256 _tokenId)
        internal
        view
    {
        //TODO: Move to storage contract
        ListNFT memory listedNFT = listNfts[_nftAddress][_tokenId];
        if (listedNFT.seller != msg.sender) {
            revert NotListedNftOwner(msg.sender, listedNFT.seller);
        }
    }

    modifier onlyListedNFTOwner(address _nftAddress, uint256 _tokenId) {
        _onlyListedNFTOwner(_nftAddress, _tokenId);
        _;
    }

    function _onlyNFTOwner(address _nftAddress, uint256 _tokenId)
        internal
        view
    {
        IERC721 nft = IERC721(_nftAddress);

        if (nft.ownerOf(_tokenId) != msg.sender) {
            revert NotNftOwner(msg.sender, nft.ownerOf(_tokenId));
        }
    }

    modifier onlyNFTOwner(address _nftAddress, uint256 _tokenId) {
        _onlyNFTOwner(_nftAddress, _tokenId);
        _;
    }

    function _onlyAfricarareNFT(address _nftAddress) internal view {
        if (!africarareNFTFactory.onlyAfricarareNFT(_nftAddress)) {
            revert NotAfricarareNFT(_nftAddress);
        }
    }

    modifier onlyAfricarareNFT(address _nftAddress) {
        _onlyAfricarareNFT(_nftAddress);
        _;
    }

    //@dev: This is a gas optimisation trick reusing function instead of require in modifier
    function _onlyListedNFT(address _nftAddress, uint256 _tokenId)
        internal
        view
    {
        //TODO: Move to storage contract
        if (listNfts[_nftAddress][_tokenId].seller == address(0)) {
            revert AddressIsZero(listNfts[_nftAddress][_tokenId].seller);
        }
        //TODO: Move to storage contract
        if (listNfts[_nftAddress][_tokenId].sold) {
            revert ItemIsSold(_nftAddress, _tokenId);
        }
    }

    modifier onlyListedNFT(address _nftAddress, uint256 _tokenId) {
        _onlyListedNFT(_nftAddress, _tokenId);
        _;
    }

    function _nonListedNFT(address _nftAddress, uint256 _tokenId)
        internal
        view
    {
        //TODO: Move to storage contract
        ListNFT memory listedNFT = listNfts[_nftAddress][_tokenId];
        if (listedNFT.seller != address(0) && !listedNFT.sold) {
            revert ItemIsAlreadyListed(_nftAddress, _tokenId);
        }
    }

    modifier nonListedNFT(address _nftAddress, uint256 _tokenId) {
        _nonListedNFT(_nftAddress, _tokenId);
        _;
    }

    function _onlyAuctioned(address _nftAddress, uint256 _tokenId)
        internal
        view
    {
        //TODO: Move to storage contract
        AuctionNFT memory auction = auctionNfts[_nftAddress][_tokenId];
        if (auction.nft == address(0)) {
            revert AddressIsZero(_nftAddress);
        }
        if (auction.complete) {
            revert AuctionsHasCompleted(_nftAddress, _tokenId);
        }
    }

    modifier onlyAuctioned(address _nftAddress, uint256 _tokenId) {
        _onlyAuctioned(_nftAddress, _tokenId);
        _;
    }

    function _nonAuctioned(address _nftAddress, uint256 _tokenId)
        internal
        view
    {
        AuctionNFT memory auction = auctionNfts[_nftAddress][_tokenId];
        if (auction.nft != address(0) && !auction.complete) {
            revert ItemIsAlreadyAuctioned(_nftAddress, _tokenId);
        }
    }

    modifier nonAuctioned(address _nftAddress, uint256 _tokenId) {
        _nonAuctioned(_nftAddress, _tokenId);
        //TODO: Move to storage contract
        _;
    }

    function _validOfferPrice(uint256 _offerPrice) internal pure {
        if (_offerPrice <= 0) {
            revert OfferPriceTooLow(_offerPrice);
        }
    }

    modifier validOfferPrice(uint256 _offerPrice) {
        _validOfferPrice(_offerPrice);
        _;
    }

    function _onlyPayableToken(address _payToken) internal view {
        //     TODO: Move to storage contract
        if (_payToken == address(0)) {
            revert AddressIsZero(_payToken);
        }
        if (!payableTokens[_payToken]) {
            revert NotValidPaymentToken(_payToken);
        }
    }

    modifier onlyPayableToken(address _payToken) {
        _onlyPayableToken(_payToken);
        _;
    }

    function _nonPayableToken(address _payToken) internal view {
        if (payableTokens[_payToken]) {
            revert PaymentTokenAlreadyExists(_payToken);
        }
    }

    modifier nonPayableToken(address _payToken) {
        _nonPayableToken(_payToken);
        _;
    }

    //@notice: List NFT
    function listNft(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken,
        uint256 _price
    )
        external
        nonReentrant
        onlyAfricarareNFT(_nftAddress)
        onlyPayableToken(_payToken)
        onlyNFTOwner(_nftAddress, _tokenId)
    {
        emit ListedNFT(_nftAddress, _tokenId, _payToken, _price, msg.sender);
        IERC721(_nftAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId
        );

        //TODO: Move to storage contract
        listNfts[_nftAddress][_tokenId] = ListNFT({
            nft: _nftAddress,
            tokenId: _tokenId,
            seller: msg.sender,
            payToken: _payToken,
            price: _price,
            sold: false
        });
    }

    //@notice: Cancel listed NFT
    function cancelListedNFT(address _nftAddress, uint256 _tokenId)
        external
        onlyListedNFT(_nftAddress, _tokenId)
        onlyListedNFTOwner(_nftAddress, _tokenId)
    {
        //TODO: Move to storage contract
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
    )
        external
        onlyListedNFT(_nftAddress, _tokenId)
        onlyPayableToken(_payToken)
        nonReentrant
    {
        //TODO: Move to storage contract
        ListNFT memory listedNft = listNfts[_nftAddress][_tokenId];

        if (listedNft.sold) {
            revert ItemIsSold(_nftAddress, _tokenId);
        }

        if (_price < listedNft.price) {
            revert InsufficientBalance(_price, listedNft.price);
        }

        listedNft.sold = true;

        uint256 totalPrice = _price;
        //TODO: Add eip royalties
        IAfricarareNFT nft = IAfricarareNFT(listedNft.nft);
        address royaltyRecipient = nft.getRoyaltyRecipient();
        uint256 royaltyFee = nft.getRoyaltyFee();

        if (royaltyFee > 0) {
            uint256 royaltyTotal = calculateRoyaltyFee(royaltyFee, _price);

            // Transfer royalty fee to collection owner
            IERC20(listedNft.payToken).safeTransferFrom(
                msg.sender,
                royaltyRecipient,
                royaltyTotal
            );
            totalPrice -= royaltyTotal;
        }

        // Calculate & Transfer platform fee
        uint256 platformFeeTotal = calculatePlatformFee(_price, platformFee);
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

    function placeOfferForNFT(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken,
        uint256 _offerPrice
    )
        external
        onlyListedNFT(_nftAddress, _tokenId)
        validOfferPrice(_offerPrice)
        nonReentrant
    {
        //TODO: Move to storage contract
        ListNFT memory nft = listNfts[_nftAddress][_tokenId];
        IERC20(nft.payToken).safeTransferFrom(
            msg.sender,
            address(this),
            _offerPrice
        );

        //TODO: Move to storage contract
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

    function _onlyNFTOffer(
        address _nftAddress,
        uint256 _tokenId,
        address _offerer
    ) internal view {
        //TODO: Move to storage contract
        OfferNFT memory offer = offerNfts[_nftAddress][_tokenId][_offerer];
        if (offer.offerPrice <= 0 || offer.offerer == address(0)) {
            revert ItemIsNotOffered(_nftAddress, _tokenId);
        }
    }

    modifier onlyNFTOffer(
        address _nftAddress,
        uint256 _tokenId,
        address _offerer
    ) {
        _onlyNFTOffer(_nftAddress, _tokenId, _offerer);
        _;
    }

    function _onlyNFTOfferOwner(address _nftAddress, uint256 _tokenId)
        internal
        view
    {
        OfferNFT memory offer = offerNfts[_nftAddress][_tokenId][msg.sender];
        if (offer.offerer != msg.sender)
            revert NotOfferer(offer.offerer, msg.sender);
    }

    modifier onlyNFTOfferOwner(
        address _nftAddress,
        uint256 _tokenId,
        address _offerer
    ) {
        _onlyNFTOfferOwner(_nftAddress, _tokenId);
        _;
    }


    function _nonAcceptedOffer(address _nftAddress, uint256 _tokenId, address _offerer) internal view {
        OfferNFT memory offer = offerNfts[_nftAddress][_tokenId][_offerer];
        if (offer.accepted) {
            revert OfferAlreadyAccepted(offer.offerer, _offerer);
        }
    }


    modifier nonAcceptedOffer(
        address _nftAddress,
        uint256 _tokenId,
        address _offerer
    ) {
        _nonAcceptedOffer(_nftAddress, _tokenId, _offerer);
        _;
    }

    // @notice Offerer cancel offering
    function cancelOfferForNFT(address _nftAddress, uint256 _tokenId)
        external
        onlyNFTOffer(_nftAddress, _tokenId, msg.sender)
        onlyNFTOfferOwner(_nftAddress, _tokenId, msg.sender)
        nonAcceptedOffer(_nftAddress, _tokenId, msg.sender)
        nonReentrant
    {
        //TODO: Move to storage contract
        OfferNFT memory offer = offerNfts[_nftAddress][_tokenId][msg.sender];
        //TODO: Move to storage contract
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
    function acceptOfferForNFT(
        address _nftAddress,
        uint256 _tokenId,
        address _offerer
    )
        external
        nonZeroAddress(_offerer)
        onlyNFTOffer(_nftAddress, _tokenId, _offerer)
        onlyListedNFT(_nftAddress, _tokenId)
        onlyListedNFTOwner(_nftAddress, _tokenId)
        nonReentrant
    {
        //TODO: Move to storage contract
        OfferNFT storage offer = offerNfts[_nftAddress][_tokenId][_offerer];
        //TODO: Move to storage contract
        ListNFT storage list = listNfts[offer.nft][offer.tokenId];

        if (list.sold) {
            revert ItemIsSold(_nftAddress, _tokenId);
        }

        if (offer.accepted) {
            revert OfferAlreadyAccepted(_offerer, msg.sender);
        }

        list.sold = true;
        offer.accepted = true;

        uint256 offerPrice = offer.offerPrice;

        //TODO: replace with standard royalties
        IAfricarareNFT nft = IAfricarareNFT(offer.nft);
        address royaltyRecipient = nft.getRoyaltyRecipient();
        uint256 royaltyFee = nft.getRoyaltyFee();

        IERC20 payToken = IERC20(offer.payToken);

        // Transfer royalty fee to collection owner
        uint256 royaltyTotal = calculateRoyaltyFee(royaltyFee, offerPrice);
        if (royaltyTotal > 0) {
            payToken.safeTransfer(royaltyRecipient, royaltyTotal);
        }

        // Calculate & Transfer platform fee
        uint256 platformFeeTotal = calculatePlatformFee(
            offerPrice,
            platformFee
        );
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
    )
        external
        onlyPayableToken(_payToken)
        nonAuctioned(_nftAddress, _tokenId)
        onlyNFTOwner(_nftAddress, _tokenId)
        nonReentrant
    {
        if (_endTime <= _startTime) {
            revert NotValidAuctionDuration(_startTime, _endTime);
        }

        //TODO: Move to storage contract
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
            complete: false
        });

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

        IERC721(_nftAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId
        );
    }

    // @notice Cancel auction
    function cancelAuction(address _nftAddress, uint256 _tokenId)
        external
        onlyAuctioned(_nftAddress, _tokenId)
        nonReentrant
    {
        //TODO: Move to storage contract
        AuctionNFT memory auction = auctionNfts[_nftAddress][_tokenId];

        if (auction.creator != msg.sender) {
            revert NotAuctionCreator(msg.sender, auction.creator);
        }

        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp >= auction.startTime) {
            // solhint-disable-next-line not-rely-on-time
            revert AuctionHasStarted(block.timestamp, auction.startTime);
        }

        if (auction.lastBidder != address(0)) {
            revert AuctionHasBidders(auction.lastBidder);
        }

        IERC721 nft = IERC721(_nftAddress);
        //TODO: Move to storage contract
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
    ) external onlyAuctioned(_nftAddress, _tokenId) nonReentrant {
        //TODO: Move to storage contract
        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp < auctionNfts[_nftAddress][_tokenId].startTime) {
            revert AuctionHasNotStarted(
                // solhint-disable-next-line not-rely-on-time
                block.timestamp,
                auctionNfts[_nftAddress][_tokenId].startTime
            );
        }

        //TODO: Move to storage contract
        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp >= auctionNfts[_nftAddress][_tokenId].endTime) {
            revert AuctionIsComplete(_nftAddress, _tokenId);
        }

        //TODO: Move to storage contract
        if (
            _bidPrice <=
            auctionNfts[_nftAddress][_tokenId].highestBid +
                auctionNfts[_nftAddress][_tokenId].minBid
        ) {
            revert BidTooLow(
                _bidPrice,
                auctionNfts[_nftAddress][_tokenId].minBid
            );
        }

        //TODO: Move to storage contract
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

    // @notice Result auction, callable by auction creator, highest bidder, or marketplace owner
    function resultAuction(address _nftAddress, uint256 _tokenId)
        external
        nonReentrant
    {
        //TODO: Move to storage contract
        AuctionNFT storage auction = auctionNfts[_nftAddress][_tokenId];
        if (auctionNfts[_nftAddress][_tokenId].complete) {
            revert AuctionIsComplete(_nftAddress, _tokenId);
        }

        if (
            msg.sender != owner() &&
            msg.sender != auction.creator &&
            msg.sender != auction.lastBidder
        ) {
            revert notAuthorisedToCallAuction(
                msg.sender,
                owner(),
                auction.creator,
                auction.lastBidder
            );
        }

        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp <= auction.endTime) {
            revert AuctionIsComplete(_nftAddress, _tokenId);
        }

        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp < auction.endTime) {
            revert AuctionIsNotComplete(_nftAddress, _tokenId);
        }

        IERC20 payToken = IERC20(auction.payToken);
        IERC721 nft = IERC721(auction.nft);

        auction.complete = true;
        auction.winner = auction.lastBidder;

        IAfricarareNFT africarareNft = IAfricarareNFT(_nftAddress);
        address royaltyRecipient = africarareNft.getRoyaltyRecipient();
        uint256 royaltyFee = africarareNft.getRoyaltyFee();

        uint256 highestBid = auction.highestBid;
        uint256 totalPrice = highestBid;

        if (royaltyFee > 0) {
            uint256 royaltyTotal = calculateRoyaltyFee(royaltyFee, highestBid);
            // Transfer royalty fee to collection owner
            payToken.safeTransfer(royaltyRecipient, royaltyTotal);
            totalPrice -= royaltyTotal;
        }

        // Calculate & Transfer platform fee
        uint256 platformFeeTotal = calculatePlatformFee(
            highestBid,
            platformFee
        );
        payToken.safeTransfer(feeRecipient, platformFeeTotal);

        // Transfer to auction creator
        payToken.safeTransfer(auction.creator, totalPrice - platformFeeTotal);

        // Transfer NFT to the winner
        nft.safeTransferFrom(address(this), auction.winner, auction.tokenId);

        emit ResultedAuction(
            _nftAddress,
            _tokenId,
            auction.creator,
            auction.winner,
            auction.highestBid,
            msg.sender
        );
    }

    function calculatePlatformFee(uint256 _price, uint256 _platformFee)
        public
        pure
        returns (uint256)
    {
        return (_price * _platformFee) / 10000;
    }

    function calculateRoyaltyFee(uint256 _royalty, uint256 _price)
        public
        pure
        returns (uint256)
    {
        return (_price * _royalty) / 10000;
    }

    //TODO: Move to storage contract
    function getListedNFT(address _nftAddress, uint256 _tokenId)
        public
        view
        returns (ListNFT memory)
    {
        return listNfts[_nftAddress][_tokenId];
    }

    //TODO: Move to storage contract
    function getPayableTokens() external view returns (address[] memory) {
        return paymentTokens;
    }

    function addPayableToken(address _paymentToken)
        external
        nonPayableToken(_paymentToken)
        nonZeroAddress(_paymentToken)
        onlyOwner
    {
        //TODO: Move to storage contract
        payableTokens[_paymentToken] = true;
        //TODO: Move to storage contract
        paymentTokens.push(_paymentToken);
    }

    //TODO: Move to storage contract
    function checkIsPayableToken(address _paymentToken)
        external
        view
        returns (bool)
    {
        return payableTokens[_paymentToken];
    }

    function updatePlatformFee(uint256 _platformFee) external onlyOwner {
        //@dev: expressed in percentage i.e 10% fee
        if (_platformFee >= 10) {
            revert PlatformFeeExceedLimit(_platformFee, 10);
        }
        emit UpdatedPlatformFee(_platformFee);
        platformFee = _platformFee;
    }

    function updateFeeRecipient(address _feeRecipient)
        external
        onlyOwner
        nonZeroAddress(_feeRecipient)
    {
        if (_feeRecipient == address(0)) {
            revert AddressIsZero(_feeRecipient);
        }

        feeRecipient = _feeRecipient;
    }
}
