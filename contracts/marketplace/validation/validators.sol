// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.17;

import {MarketplaceStructs} from "../structures/MarketplaceStructs.sol";
import {MarketplaceErrors} from "../errors/errors.sol";
import "../interfaces/IAfricarareNFTFactory.sol";

abstract contract MarketplaceValidators {
    function beforeNonZeroAddress(address _address) internal pure {
        if (_address == address(0)) {
            revert MarketplaceErrors.AddressIsZero(_address);
        }
    }

    modifier nonZeroAddress(address _address) {
        beforeNonZeroAddress(_address);
        _;
    }

    function beforeOnlySufficientTransferAmount(
        MarketplaceStructs.ListNFT memory _listing,
        uint256 _amountSent
    ) internal pure {
        //TODO: Move to storage contract
        if (_amountSent < _listing.price) {
            revert MarketplaceErrors.InsufficientBalanceForItem(_listing, _amountSent);
        }
    }

    modifier onlySufficientTransferAmount(
        MarketplaceStructs.ListNFT memory _listing,
        uint256 _amountSent
    ) {
        beforeOnlySufficientTransferAmount(_listing, _amountSent);
        _;
    }

    function beforeOnlyListedNFTOwner(
        MarketplaceStructs.ListNFT memory _listing,
        address _sender
    ) internal pure {
        //TODO: Move to storage contract
        if (_listing.seller != _sender) {
            revert MarketplaceErrors.NotListedNftOwner(_listing, _sender);
        }
    }

    modifier onlyListedNFTOwner(
        MarketplaceStructs.ListNFT memory _listing,
        address _sender
    ) {
        beforeOnlyListedNFTOwner(_listing, _sender);
        _;
    }

    function beforeOnlyNFTOwner(address _nftOwner, address _sender)
        internal
        pure
    {
        if (_nftOwner != _sender) {
            revert MarketplaceErrors.NotNftOwner(_nftOwner, _sender);
        }
    }

    modifier onlyNFTOwner(address _nftOwner, address _sender) {
        beforeOnlyNFTOwner(_nftOwner, _sender);
        _;
    }

    function beforeOnlyAfricarareNFT(bool _isAfricarareNFT, address _nftAddress)
        internal
        pure
    {
        if (!_isAfricarareNFT) {
            revert MarketplaceErrors.NotAfricarareNFT(_nftAddress);
        }
    }

    modifier onlyAfricarareNFT(bool _isAfricarareNFT, address _nftAddress) {
        beforeOnlyAfricarareNFT(_isAfricarareNFT, _nftAddress);
        _;
    }

    //@dev: This is a gas optimislation trick reusing function instead of require in modifier
    function beforeOnlyListedNFT(MarketplaceStructs.ListNFT memory _listing)
        internal
        pure
    {
        //TODO: Move to storage contract
        //FIXME: move this zero check somewhere better or remove it for explicit zero check modifier?
        if (_listing.seller == address(0)) {
            revert MarketplaceErrors.AddressIsZero(_listing.seller);
        }
        //TODO: Move to storage contract
        if (_listing.sold) {
            revert MarketplaceErrors.ItemIsSold(_listing);
        }
    }

    modifier onlyListedNFT(MarketplaceStructs.ListNFT memory _listing) {
        beforeOnlyListedNFT(_listing);
        _;
    }

    function beforeNonListedNFT(MarketplaceStructs.ListNFT memory _listing)
        internal
        pure
    {
        //TODO: Move to storage contract
        if (_listing.seller != address(0) && _listing.sold) {
            revert MarketplaceErrors.ItemIsAlreadyListed(_listing);
        }
    }

    modifier nonListedNFT(MarketplaceStructs.ListNFT memory _listing) {
        beforeNonListedNFT(_listing);
        _;
    }

    function beforeOnlyValidAuctionDuration(
        uint256 _startTime,
        uint256 _endTime
    ) internal pure {
        if (_endTime <= _startTime) {
            revert MarketplaceErrors.NotValidAuctionDuration(_startTime, _endTime);
        }
    }

    modifier onlyValidAuctionDuration(uint256 _startTime, uint256 _endTime) {
        beforeOnlyValidAuctionDuration(_startTime, _endTime);
        _;
    }

    function beforeOnlyStartedAuction(
        MarketplaceStructs.AuctionNFT memory _auction,
        uint256 _timestamp
    ) internal pure {
        if (_timestamp < _auction.startTime) {
            revert MarketplaceErrors.AuctionIsNotStarted(
                // solhint-disable-next-line not-rely-on-time
                _auction,
                _timestamp
            );
        }
    }

    modifier onlyStartedAuction(
        MarketplaceStructs.AuctionNFT memory _auction,
        uint256 _timestamp
    ) {
        beforeOnlyStartedAuction(_auction, _timestamp);
        _;
    }

    function beforeNonStartedAuction(
        MarketplaceStructs.AuctionNFT memory _auction,
        uint256 _timestamp
    ) internal pure {
        if (_timestamp >= _auction.startTime) {
            // solhint-disable-next-line not-rely-on-time
            revert MarketplaceErrors.AuctionIsStarted(_auction, _timestamp);
        }
    }

    modifier nonStartedAuction(
        MarketplaceStructs.AuctionNFT memory _auction,
        uint256 _timestamp
    ) {
        beforeNonStartedAuction(_auction, _timestamp);
        _;
    }

    function beforeOnlyFinishedAuction(
        MarketplaceStructs.AuctionNFT memory _auction,
        uint256 _timestamp
    ) internal pure {
        //TODO: Move to storage contract
        // solhint-disable-next-line not-rely-on-time
        if (_timestamp <= _auction.endTime) {
            revert MarketplaceErrors.AuctionIsNotFinished(_auction, _timestamp);
        }
    }

    modifier onlyFinishedAuction(
        MarketplaceStructs.AuctionNFT memory _auction,
        uint256 _timestamp
    ) {
        beforeOnlyFinishedAuction(_auction, _timestamp);
        _;
    }

    function beforeOnlySufficientBidAmount(
        MarketplaceStructs.AuctionNFT memory _auction,
        uint256 _bidAmount
    ) internal pure {
        if (_bidAmount <= _auction.highestBid + _auction.minBid) {
            revert MarketplaceErrors.BidTooLow(_bidAmount, _auction.minBid);
        }
    }

    modifier onlySufficientBidAmount(
        MarketplaceStructs.AuctionNFT memory _auction,
        uint256 _bidAmount
    ) {
        beforeOnlySufficientBidAmount(_auction, _bidAmount);
        _;
    }

    function beforeNonFinishedAuction(
        MarketplaceStructs.AuctionNFT memory _auction,
        uint256 _timestamp
    ) internal pure {
        //TODO: Move to storage contract
        // solhint-disable-next-line not-rely-on-time
        if (_timestamp >= _auction.endTime) {
            revert MarketplaceErrors.AuctionIsFinished(_auction, _timestamp);
        }
    }

    modifier nonFinishedAuction(
        MarketplaceStructs.AuctionNFT memory _auction,
        uint256 _timestamp
    ) {
        beforeNonFinishedAuction(_auction, _timestamp);
        _;
    }

    function beforeNonCalledAuction(MarketplaceStructs.AuctionNFT memory _auction)
        internal
        pure
    {
        if (_auction.called) {
            revert MarketplaceErrors.AuctionIsCalled(_auction);
        }
    }

    modifier nonCalledAuction(MarketplaceStructs.AuctionNFT memory _auction) {
        beforeNonCalledAuction(_auction);
        _;
    }

    function beforeOnlyAuctioned(MarketplaceStructs.AuctionNFT memory _auction)
        internal
        pure
    {
        //TODO: Move to storage contract
        if (_auction.nft == address(0)) {
            revert MarketplaceErrors.AddressIsZero(_auction.nft);
        }
        if (_auction.called) {
            revert MarketplaceErrors.AuctionIsCalled(_auction);
        }
    }

    modifier onlyAuctioned(MarketplaceStructs.AuctionNFT memory _auction) {
        beforeOnlyAuctioned(_auction);
        _;
    }

    function beforeNonAuctioned(MarketplaceStructs.AuctionNFT memory _auction)
        internal
        pure
    {
        if (_auction.nft != address(0) && !_auction.called) {
            revert MarketplaceErrors.ItemIsAlreadyAuctioned(_auction);
        }
    }

    modifier nonAuctioned(MarketplaceStructs.AuctionNFT memory _auction) {
        beforeNonAuctioned(_auction);
        _;
    }

    function beforeOnlyAuctionCreator(
        MarketplaceStructs.AuctionNFT memory _auction,
        address _sender
    ) internal pure {
        if (_auction.creator != _sender) {
            revert MarketplaceErrors.NotAuctionCreator(_auction, _sender);
        }
    }

    modifier onlyAuctionCreator(
        MarketplaceStructs.AuctionNFT memory _auction,
        address _sender
    ) {
        beforeOnlyAuctionCreator(_auction, _sender);
        _;
    }

    function beforeNonBiddedAuction(MarketplaceStructs.AuctionNFT memory _auction)
        internal
        pure
    {
        if (_auction.lastBidder != address(0)) {
            revert MarketplaceErrors.AuctionHasBidders(_auction);
        }
    }

    modifier nonBiddedAuction(MarketplaceStructs.AuctionNFT memory _auction) {
        beforeNonBiddedAuction(_auction);
        _;
    }

    function beforeOnlyAuthorisedAuctionCaller(
        MarketplaceStructs.AuctionNFT memory _auction,
        address _marketplaceOwner,
        address _sender
    ) internal pure {
        if (
            _sender != _marketplaceOwner &&
            _sender != _auction.creator &&
            _sender != _auction.lastBidder
        ) {
            revert MarketplaceErrors.notAuthorisedToCallAuction(
                _sender,
                _marketplaceOwner,
                _auction.creator,
                _auction.lastBidder
            );
        }
    }

    modifier onlyAuthorisedAuctionCaller(
        MarketplaceStructs.AuctionNFT memory _auction,
        address _marketplaceOwner,
        address _sender
    ) {
        beforeOnlyAuthorisedAuctionCaller(_auction, _marketplaceOwner, _sender);
        _;
    }

    function _validOfferPrice(uint256 _offerPrice) internal pure {
        if (_offerPrice <= 0) {
            revert MarketplaceErrors.OfferPriceTooLow(_offerPrice);
        }
    }

    modifier validOfferPrice(uint256 _offerPrice) {
        _validOfferPrice(_offerPrice);
        _;
    }

    function beforeOnlyNFTOffer(MarketplaceStructs.OfferNFT memory _offer)
        internal
        pure
    {
        //TODO: Move to storage contract
        if (_offer.offerPrice <= 0 || _offer.offerer == address(0)) {
            revert MarketplaceErrors.ItemIsNotOffered(_offer);
        }
    }

    modifier onlyNFTOffer(MarketplaceStructs.OfferNFT memory _offer) {
        beforeOnlyNFTOffer(_offer);
        _;
    }

    function beforeOnlyNFTOfferOwner(
        MarketplaceStructs.OfferNFT memory _offer,
        address _sender
    ) internal pure {
        if (_offer.offerer != _sender)
            revert MarketplaceErrors.NotOfferer(_offer.offerer, _sender);
    }

    modifier onlyNFTOfferOwner(
        MarketplaceStructs.OfferNFT memory _offer,
        address _sender
    ) {
        beforeOnlyNFTOfferOwner(_offer, _sender);
        _;
    }

    function beforeNonAcceptedOffer(
        MarketplaceStructs.OfferNFT memory _offer,
        address _sender
    ) internal pure {
        if (_offer.accepted) {
            revert MarketplaceErrors.OfferAlreadyAccepted(_offer.offerer, _sender);
        }
    }

    modifier nonAcceptedOffer(
        MarketplaceStructs.OfferNFT memory _offer,
        address _sender
    ) {
        beforeNonAcceptedOffer(_offer, _sender);
        _;
    }

    //FIXME: make these pure
    function beforeOnlyPayableToken(bool _exists) internal pure {
        //     TODO: Move to storage contract
        //FIXME: determine if zero check is needed
        // if (_payToken == address(0)) {
        //     revert MarketplaceErrors.AddressIsZero(_payToken);
        // }
        if (!_exists) {
            revert MarketplaceErrors.NotValidPaymentToken();
        }
    }

    modifier onlyPayableToken(bool _exists) {
        beforeOnlyPayableToken(_exists);
        _;
    }

    function beforeNonPayableToken(bool _exists, address _payToken)
        internal
        pure
    {
        if (_exists) {
            revert MarketplaceErrors.PaymentTokenAlreadyExists(_payToken);
        }
    }

    modifier nonPayableToken(bool _exists, address _payToken) {
        beforeNonPayableToken(_exists, _payToken);
        _;
    }
}
