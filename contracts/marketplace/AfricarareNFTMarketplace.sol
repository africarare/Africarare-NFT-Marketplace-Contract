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
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "hardhat/console.sol";

import "./interfaces/IAfricarareNFTFactory.sol";
import "./interfaces/IAfricarareNFT.sol";
import "./errors/errors.sol";
import "./structures/structs.sol";
import {MarketplaceValidators} from "./validation/validators.sol";
import {MarketplaceEvents} from "./events/events.sol";
import {IERC2981Support} from "./royalties/IERC2981Support.sol";

// import {IERC2981Support} from "./events/events.sol";

/*
    @dev: Africarare NFT Marketplace
    @dev: auction NFT,
    @dev: Buy NFT,
    @dev: Offer NFT,
    @dev: Accept offer,
    @dev: Create auction,
    @dev: Bid place,
    @dev: Support Royalty,
    @TODO: Support ERC1155,
    @TODO: Store assets in storage contract,
    @TODO: end to end unit test all custom errors and exceptions
    @TODO: clean up offer, auction logic
    @TODO: add timestamps to structs and events
    @TODO: use safe 1155, 721 interfaces like safe erc20?
    @TODO: remove payable tokens as well as add them
    @TODO: test fee logic math is correctly deducting right amounts
    @TODO: remove uint256 for uint, let compiler optimise, or at least try

*/

contract AfricarareNFTMarketplace is
    ERC721HolderUpgradeable,
    ERC1155HolderUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    MarketplaceEvents,
    MarketplaceValidators,
    IERC2981Support
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
    IAfricarareNFTFactory private immutable africarareNFTFactory;

    //@dev: fee is in basis points e.g 400/10000  = 4%
    uint96 private immutable feeDenominator = 10000;
    uint256 private platformFee;
    address private feeRecipient;

    mapping(address => bool) private payableTokens;
    address[] private paymentTokens;

    //TODO: Move to storage contract
    // @dev: nft => tokenId => auction struct
    mapping(address => mapping(uint256 => ListNFT)) private listNfts;

    // @dev: nft => tokenId => offerer address => offer struct
    mapping(address => mapping(uint256 => mapping(address => OfferNFT)))
        private offerNfts;

    // @dev: nft => tokenId => auction struct
    mapping(address => mapping(uint256 => AuctionNFT)) private auctionNfts;

    // @dev: auction index => bidding counts => bidder address => bid price
    mapping(uint256 => mapping(uint256 => mapping(address => uint256)))
        private bidPrices;

    function initialize() public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __ERC1155Holder_init();
        __ERC721Holder_init();
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        uint256 _platformFee,
        address _feeRecipient,
        IAfricarareNFTFactory _africarareNFTFactory
    ) initializer {
        initialize();
        if (_platformFee > 1000)
            revert PlatformFeeExceedLimit(_platformFee, 1000);

        platformFee = _platformFee;

        if (_feeRecipient != address(0)) {
            feeRecipient = _feeRecipient;
        }
        africarareNFTFactory = _africarareNFTFactory;
    }

    //@notice: auction NFT
    function listNft(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken,
        uint256 _price
    )
        external
        nonReentrant
        onlyPayableToken(payableTokens[_payToken])
        onlyNFTOwner(
            IERC721Upgradeable(_nftAddress).ownerOf(_tokenId),
            _msgSender()
        )
    {
        emit ListedNFT(_nftAddress, _tokenId, _payToken, _price, _msgSender());
        IERC721Upgradeable(_nftAddress).safeTransferFrom(
            _msgSender(),
            address(this),
            _tokenId
        );

        //TODO: Move to storage contract
        listNfts[_nftAddress][_tokenId] = ListNFT({
            nft: _nftAddress,
            tokenId: _tokenId,
            seller: _msgSender(),
            payToken: _payToken,
            price: _price,
            sold: false
        });
    }

    //@notice: Cancel listed NFT
    function cancelListedNFT(address _nftAddress, uint256 _tokenId)
        external
        onlyListedNFT(listNfts[_nftAddress][_tokenId])
        onlyListedNFTOwner(listNfts[_nftAddress][_tokenId], _msgSender())
    {
        //TODO: Move to storage contract
        delete listNfts[_nftAddress][_tokenId];
        IERC721Upgradeable(_nftAddress).safeTransferFrom(
            address(this),
            _msgSender(),
            _tokenId
        );
    }

    // @notice: Buy listed NFT
    function buyNFT(
        address _nftAddress,
        uint256 _tokenId,
        address _payToken
    )
        external
        onlySufficientTransferAmount(
            listNfts[_nftAddress][_tokenId],
            listNfts[_nftAddress][_tokenId].price
        )
        onlyListedNFT(listNfts[_nftAddress][_tokenId])
        onlyPayableToken(payableTokens[_payToken])
        nonReentrant
    {
        //TODO: Move to storage contract
        ListNFT memory listing = listNfts[_nftAddress][_tokenId];

        listing.sold = true;

        // FIXME: check if this mutatble use of totalPrice is safe
        uint256 totalPrice = listing.price;
        (address royaltyRecipient, uint256 royaltyFee) = getIERC2981Royalty(
            listing.nft,
            listing.tokenId,
            listing.price
        );

        if (royaltyFee > 0) {
            uint256 royaltyTotal = calculateFee(royaltyFee, listing.price);

            // Transfer royalty fee to collection owner
            IERC20Upgradeable(listing.payToken).safeTransferFrom(
                _msgSender(),
                royaltyRecipient,
                royaltyTotal
            );
            totalPrice -= royaltyTotal;
        }

        // Calculate & Transfer platform fee
        uint256 platformFeeTotal = calculateFee(platformFee, listing.price);
        IERC20Upgradeable(listing.payToken).safeTransferFrom(
            _msgSender(),
            feeRecipient,
            platformFeeTotal
        );

        // Transfer to nft ownerlisting.
        IERC20Upgradeable(listing.payToken).safeTransferFrom(
            _msgSender(),
            listing.seller,
            totalPrice - platformFeeTotal
        );

        // Transfer NFT to buyer
        IERC721Upgradeable(listing.nft).safeTransferFrom(
            address(this),
            _msgSender(),
            listing.tokenId
        );

        emit BoughtNFT(
            listing.nft,
            listing.tokenId,
            listing.payToken,
            listing.price,
            listing.seller,
            _msgSender()
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
        IERC20Upgradeable(nft.payToken).safeTransferFrom(
            _msgSender(),
            address(this),
            _offerPrice
        );

        //TODO: Move to storage contract
        offerNfts[_nftAddress][_tokenId][_msgSender()] = OfferNFT({
            nft: nft.nft,
            tokenId: nft.tokenId,
            offerer: _msgSender(),
            payToken: _payToken,
            offerPrice: _offerPrice,
            accepted: false
        });

        emit OfferedNFT(
            nft.nft,
            nft.tokenId,
            nft.payToken,
            _offerPrice,
            _msgSender()
        );
    }

    // @notice Offerer cancel offering
    function cancelOfferForNFT(address _nftAddress, uint256 _tokenId)
        external
        onlyNFTOffer(offerNfts[_nftAddress][_tokenId][_msgSender()])
        onlyNFTOfferOwner(
            offerNfts[_nftAddress][_tokenId][_msgSender()],
            _msgSender()
        )
        nonAcceptedOffer(
            offerNfts[_nftAddress][_tokenId][_msgSender()],
            _msgSender()
        )
        nonReentrant
    {
        //TODO: Move to storage contract
        OfferNFT memory offer = offerNfts[_nftAddress][_tokenId][_msgSender()];
        //TODO: Move to storage contract
        delete offerNfts[_nftAddress][_tokenId][_msgSender()];
        IERC20Upgradeable(offer.payToken).safeTransfer(
            offer.offerer,
            offer.offerPrice
        );
        emit CanceledOfferedNFT(
            offer.nft,
            offer.tokenId,
            offer.payToken,
            offer.offerPrice,
            _msgSender()
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
        onlyListedNFTOwner(listNfts[_nftAddress][_tokenId], _msgSender())
        nonAcceptedOffer(offerNfts[_nftAddress][_tokenId][_offerer], _offerer)
        nonZeroAddress(_offerer)
        nonReentrant
    {
        //TODO: Move to storage contract
        OfferNFT storage offer = offerNfts[_nftAddress][_tokenId][_offerer];
        //TODO: Move to storage contract
        ListNFT storage auction = listNfts[offer.nft][offer.tokenId];

        auction.sold = true;
        offer.accepted = true;

        uint256 offerPrice = offer.offerPrice;

        (address royaltyRecipient, uint256 royaltyFee) = getIERC2981Royalty(
            auction.nft,
            auction.tokenId,
            auction.price
        );

        IERC20Upgradeable payToken = IERC20Upgradeable(offer.payToken);

        // Transfer royalty fee to collection owner
        uint256 royaltyTotal = calculateFee(royaltyFee, offerPrice);
        if (royaltyTotal > 0) {
            payToken.safeTransfer(royaltyRecipient, royaltyTotal);
        }

        // Calculate & Transfer platform fee
        uint256 platformFeeTotal = calculateFee(platformFee, offerPrice);
        if (platformFeeTotal > 0) {
            payToken.safeTransfer(feeRecipient, platformFeeTotal);
        }

        // Transfer to seller
        payToken.safeTransfer(
            auction.seller,
            offerPrice - platformFeeTotal - royaltyTotal
        );

        // Transfer NFT to offerer
        IERC721Upgradeable(auction.nft).safeTransferFrom(
            address(this),
            offer.offerer,
            auction.tokenId
        );

        emit AcceptedNFT(
            offer.nft,
            offer.tokenId,
            offer.payToken,
            offer.offerPrice,
            offer.offerer,
            auction.seller
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
        onlyNFTOwner(
            IERC721Upgradeable(_nftAddress).ownerOf(_tokenId),
            _msgSender()
        )
        onlyValidAuctionDuration(_startTime, _endTime)
        nonAuctioned(auctionNfts[_nftAddress][_tokenId])
        nonReentrant
    {
        //TODO: Move to storage contract
        auctionNfts[_nftAddress][_tokenId] = AuctionNFT({
            nft: _nftAddress,
            tokenId: _tokenId,
            creator: _msgSender(),
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
            _msgSender()
        );

        IERC721Upgradeable(_nftAddress).safeTransferFrom(
            _msgSender(),
            address(this),
            _tokenId
        );
    }

    // @notice Cancel auction
    function cancelAuction(address _nftAddress, uint256 _tokenId)
        external
        onlyAuctioned(auctionNfts[_nftAddress][_tokenId])
        onlyAuctionCreator(auctionNfts[_nftAddress][_tokenId], _msgSender())
        // solhint-disable-next-line not-rely-on-time
        nonStartedAuction(auctionNfts[_nftAddress][_tokenId], block.timestamp)
        nonBiddedAuction(auctionNfts[_nftAddress][_tokenId])
        nonReentrant
    {
        // FIXME: determine if this is safe
        delete auctionNfts[_nftAddress][_tokenId];

        IERC721Upgradeable(_nftAddress).safeTransferFrom(
            address(this),
            _msgSender(),
            _tokenId
        );

        emit CancelledAuction(
            _nftAddress,
            _tokenId,
            // solhint-disable-next-line not-rely-on-time
            block.timestamp,
            _msgSender()
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
        IERC20Upgradeable payToken = IERC20Upgradeable(auction.payToken);
        // Set new highest bid price
        auction.lastBidder = _msgSender();
        auction.highestBid = _bidPrice;
        payToken.safeTransferFrom(_msgSender(), address(this), _bidPrice);

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
            _msgSender()
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
            _msgSender()
        )
    {
        //TODO: Move to storage contract
        AuctionNFT storage auction = auctionNfts[_nftAddress][_tokenId];

        auction.called = true;
        auction.winner = auction.lastBidder;

        (address royaltyRecipient, uint256 royaltyFee) = getIERC2981Royalty(
            auction.nft,
            auction.tokenId,
            auction.highestBid
        );

        uint256 highestBid = auction.highestBid;
        //FIXME: determine if this is safe
        uint256 totalPrice = highestBid;

        if (royaltyFee > 0) {
            uint256 royaltyTotal = calculateFee(royaltyFee, highestBid);
            // Transfer royalty fee to collection owner
            IERC20Upgradeable(auction.payToken).safeTransfer(
                royaltyRecipient,
                royaltyTotal
            );
            totalPrice -= royaltyTotal;
        }

        // Calculate & Transfer platform fee
        uint256 platformFeeTotal = calculateFee(platformFee, highestBid);
        //Transfer to the platform
        IERC20Upgradeable(auction.payToken).safeTransfer(
            feeRecipient,
            platformFeeTotal
        );

        // Transfer to auction creator
        IERC20Upgradeable(auction.payToken).safeTransfer(
            auction.creator,
            totalPrice - platformFeeTotal
        );

        // Transfer NFT to the winner
        IERC721Upgradeable(auction.nft).safeTransferFrom(
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
            _msgSender()
        );
    }

    function calculateFee(uint256 _fee, uint256 _price)
        public
        pure
        returns (uint256)
    {
        return _price * (_fee / feeDenominator);
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
