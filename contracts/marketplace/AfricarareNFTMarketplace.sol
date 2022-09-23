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
import "./validation/validators.sol";
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
    MarketplaceEvents,
    MarketplaceValidators
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

    //@notice: List NFT
    function listNft(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken,
        uint256 _price
    )
        external
        nonReentrant
        onlyAfricarareNFT(africarareNFTFactory, _nftAddress)
        onlyPayableToken(payableTokens[_payToken])
        onlyNFTOwner(IERC721(_nftAddress).ownerOf(_tokenId), msg.sender)
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
        onlyListedNFT(listNfts[_nftAddress][_tokenId])
        onlyListedNFTOwner(listNfts[_nftAddress][_tokenId], msg.sender)
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
        onlySufficientTransferAmount(listNfts[_nftAddress][_tokenId], _price)
        onlyListedNFT(listNfts[_nftAddress][_tokenId])
        onlyPayableToken(payableTokens[_payToken])
        nonReentrant
    {
        //TODO: Move to storage contract
        ListNFT memory listedNft = listNfts[_nftAddress][_tokenId];

        listedNft.sold = true;

        // FIXME: check if this mutatble use of totalPrice is safe
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
        onlyListedNFT(listNfts[_nftAddress][_tokenId])
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

    // @notice Offerer cancel offering
    function cancelOfferForNFT(address _nftAddress, uint256 _tokenId)
        external
        onlyNFTOffer(offerNfts[_nftAddress][_tokenId][msg.sender])
        onlyNFTOfferOwner(
            offerNfts[_nftAddress][_tokenId][msg.sender],
            msg.sender
        )
        nonAcceptedOffer(
            offerNfts[_nftAddress][_tokenId][msg.sender],
            msg.sender
        )
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
        onlyNFTOffer(offerNfts[_nftAddress][_tokenId][_offerer])
        onlyListedNFT(listNfts[_nftAddress][_tokenId])
        onlyListedNFTOwner(listNfts[_nftAddress][_tokenId], msg.sender)
        nonAcceptedOffer(offerNfts[_nftAddress][_tokenId][_offerer], _offerer)
        nonZeroAddress(_offerer)
        nonReentrant
    {
        //TODO: Move to storage contract
        OfferNFT storage offer = offerNfts[_nftAddress][_tokenId][_offerer];
        //TODO: Move to storage contract
        ListNFT storage list = listNfts[offer.nft][offer.tokenId];

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
        onlyPayableToken(payableTokens[_payToken])
        onlyNFTOwner(IERC721(_nftAddress).ownerOf(_tokenId), msg.sender)
        onlyValidAuctionDuration(_startTime, _endTime)
        nonAuctioned(auctionNfts[_nftAddress][_tokenId])
        nonReentrant
    {
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
            called: false
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
        onlyAuctioned(auctionNfts[_nftAddress][_tokenId])
        onlyAuctionCreator(auctionNfts[_nftAddress][_tokenId], msg.sender)
        // solhint-disable-next-line not-rely-on-time
        nonStartedAuction(auctionNfts[_nftAddress][_tokenId], block.timestamp)
        nonBiddedAuction(auctionNfts[_nftAddress][_tokenId])
        nonReentrant
    {
        // FIXME: determine if this is safe
        delete auctionNfts[_nftAddress][_tokenId];

        IERC721(_nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );

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
    )
        external
        onlyAuctioned(auctionNfts[_nftAddress][_tokenId])
        nonReentrant
        // solhint-disable-next-line not-rely-on-time
        nonFinishedAuction(auctionNfts[_nftAddress][_tokenId], block.timestamp)
        // solhint-disable-next-line not-rely-on-time
        onlyStartedAuction(auctionNfts[_nftAddress][_tokenId], block.timestamp)
        onlySufficientBidAmount(auctionNfts[_nftAddress][_tokenId], _bidPrice)
    {
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
        nonCalledAuction(auctionNfts[_nftAddress][_tokenId])
        // solhint-disable-next-line not-rely-on-time
        onlyFinishedAuction(auctionNfts[_nftAddress][_tokenId], block.timestamp)
        onlyAuthorisedAuctionCaller(
            auctionNfts[_nftAddress][_tokenId],
            owner(),
            msg.sender
        )
    {
        //TODO: Move to storage contract
        AuctionNFT storage auction = auctionNfts[_nftAddress][_tokenId];

        auction.called = true;
        auction.winner = auction.lastBidder;

        IAfricarareNFT africarareNft = IAfricarareNFT(_nftAddress);
        address royaltyRecipient = africarareNft.getRoyaltyRecipient();

        uint256 highestBid = auction.highestBid;
        //FIXME: determine if this is safe
        uint256 totalPrice = highestBid;

        if (africarareNft.getRoyaltyFee() > 0) {
            uint256 royaltyTotal = calculateRoyaltyFee(
                africarareNft.getRoyaltyFee(),
                highestBid
            );
            // Transfer royalty fee to collection owner
            IERC20(auction.payToken).safeTransfer(
                royaltyRecipient,
                royaltyTotal
            );
            totalPrice -= royaltyTotal;
        }

        // Calculate & Transfer platform fee
        uint256 platformFeeTotal = calculatePlatformFee(
            highestBid,
            platformFee
        );
        //Transfer to the platform
        IERC20(auction.payToken).safeTransfer(feeRecipient, platformFeeTotal);

        // Transfer to auction creator
        IERC20(auction.payToken).safeTransfer(
            auction.creator,
            totalPrice - platformFeeTotal
        );

        // Transfer NFT to the winner
        IERC721(auction.nft).safeTransferFrom(
            address(this),
            auction.winner,
            auction.tokenId
        );

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
        nonPayableToken(payableTokens[_paymentToken], _paymentToken)
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
