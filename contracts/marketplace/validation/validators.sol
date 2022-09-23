// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.7;

import "../structures/structs.sol";
import "../errors/errors.sol";
import "../interfaces/IAfricarareNFTFactory.sol";

abstract contract MarketplaceValidators {
    function beforeNonZeroAddress(address _address) internal pure {
        if (_address == address(0)) {
            revert AddressIsZero(_address);
        }
    }

    modifier nonZeroAddress(address _address) {
        beforeNonZeroAddress(_address);
        _;
    }

    function beforeOnlySufficientTransferAmount(
        ListNFT memory _listing,
        uint256 _amountSent
    ) internal pure {
        //TODO: Move to storage contract
        if (_amountSent < _listing.price) {
            revert InsufficientBalanceForItem(_listing, _amountSent);
        }
    }

    modifier onlySufficientTransferAmount(
        ListNFT memory _listing,
        uint256 _amountSent
    ) {
        beforeOnlySufficientTransferAmount(_listing, _amountSent);
        _;
    }

    function beforeOnlyListedNFTOwner(ListNFT memory _listing, address _sender)
        internal
        pure
    {
        //TODO: Move to storage contract
        if (_listing.seller != _sender) {
            revert NotListedNftOwner(_listing, _sender);
        }
    }

    modifier onlyListedNFTOwner(ListNFT memory _listing, address _sender) {
        beforeOnlyListedNFTOwner(_listing, _sender);
        _;
    }

    function beforeOnlyNFTOwner(address _nftOwner, address _sender)
        internal
        pure
    {
        if (_nftOwner != _sender) {
            revert NotNftOwner(_nftOwner, _sender);
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
            revert NotAfricarareNFT(_nftAddress);
        }
    }

    modifier onlyAfricarareNFT(bool _isAfricarareNFT, address _nftAddress) {
        beforeOnlyAfricarareNFT(_isAfricarareNFT, _nftAddress);
        _;
    }

    //@dev: This is a gas optimislation trick reusing function instead of require in modifier
    function beforeOnlyListedNFT(ListNFT memory _listing) internal pure {
        //TODO: Move to storage contract
        //FIXME: move this zero check somewhere better or remove it for explicit zero check modifier?
        if (_listing.seller == address(0)) {
            revert AddressIsZero(_listing.seller);
        }
        //TODO: Move to storage contract
        if (_listing.sold) {
            revert ItemIsSold(_listing);
        }
    }

    modifier onlyListedNFT(ListNFT memory _listing) {
        beforeOnlyListedNFT(_listing);
        _;
    }

    function beforeNonListedNFT(ListNFT memory _listing) internal pure {
        //TODO: Move to storage contract
        if (_listing.seller != address(0) && _listing.sold) {
            revert ItemIsAlreadyListed(_listing);
        }
    }

    modifier nonListedNFT(ListNFT memory _listing) {
        beforeNonListedNFT(_listing);
        _;
    }

    function beforeOnlyValidAuctionDuration(
        uint256 _startTime,
        uint256 _endTime
    ) internal pure {
        if (_endTime <= _startTime) {
            revert NotValidAuctionDuration(_startTime, _endTime);
        }
    }

    modifier onlyValidAuctionDuration(uint256 _startTime, uint256 _endTime) {
        beforeOnlyValidAuctionDuration(_startTime, _endTime);
        _;
    }

    function beforeOnlyStartedAuction(
        AuctionNFT memory _auction,
        uint256 _timestamp
    ) internal pure {
        if (_timestamp < _auction.startTime) {
            revert AuctionIsNotStarted(
                // solhint-disable-next-line not-rely-on-time
                _auction,
                _timestamp
            );
        }
    }

    modifier onlyStartedAuction(
        AuctionNFT memory _auction,
        uint256 _timestamp
    ) {
        beforeOnlyStartedAuction(_auction, _timestamp);
        _;
    }

    function beforeNonStartedAuction(
        AuctionNFT memory _auction,
        uint256 _timestamp
    ) internal pure {
        if (_timestamp >= _auction.startTime) {
            // solhint-disable-next-line not-rely-on-time
            revert AuctionIsStarted(_auction, _timestamp);
        }
    }

    modifier nonStartedAuction(AuctionNFT memory _auction, uint256 _timestamp) {
        beforeNonStartedAuction(_auction, _timestamp);
        _;
    }

    function beforeOnlyFinishedAuction(
        AuctionNFT memory _auction,
        uint256 _timestamp
    ) internal pure {
        //TODO: Move to storage contract
        // solhint-disable-next-line not-rely-on-time
        if (_timestamp <= _auction.endTime) {
            revert AuctionIsNotFinished(_auction, _timestamp);
        }
    }

    modifier onlyFinishedAuction(
        AuctionNFT memory _auction,
        uint256 _timestamp
    ) {
        beforeOnlyFinishedAuction(_auction, _timestamp);
        _;
    }

    function beforeOnlySufficientBidAmount(
        AuctionNFT memory _auction,
        uint256 _bidAmount
    ) internal pure {
        if (_bidAmount <= _auction.highestBid + _auction.minBid) {
            revert BidTooLow(_bidAmount, _auction.minBid);
        }
    }

    modifier onlySufficientBidAmount(
        AuctionNFT memory _auction,
        uint256 _bidAmount
    ) {
        beforeOnlySufficientBidAmount(_auction, _bidAmount);
        _;
    }

    function beforeNonFinishedAuction(
        AuctionNFT memory _auction,
        uint256 _timestamp
    ) internal pure {
        //TODO: Move to storage contract
        // solhint-disable-next-line not-rely-on-time
        if (_timestamp >= _auction.endTime) {
            revert AuctionIsFinished(_auction, _timestamp);
        }
    }

    modifier nonFinishedAuction(
        AuctionNFT memory _auction,
        uint256 _timestamp
    ) {
        beforeNonFinishedAuction(_auction, _timestamp);
        _;
    }

    function beforeNonCalledAuction(AuctionNFT memory _auction) internal pure {
        if (_auction.called) {
            revert AuctionIsCalled(_auction);
        }
    }

    modifier nonCalledAuction(AuctionNFT memory _auction) {
        beforeNonCalledAuction(_auction);
        _;
    }

    function beforeOnlyAuctioned(AuctionNFT memory _auction) internal pure {
        //TODO: Move to storage contract
        if (_auction.nft == address(0)) {
            revert AddressIsZero(_auction.nft);
        }
        if (_auction.called) {
            revert AuctionIsCalled(_auction);
        }
    }

    modifier onlyAuctioned(AuctionNFT memory _auction) {
        beforeOnlyAuctioned(_auction);
        _;
    }

    function beforeNonAuctioned(AuctionNFT memory _auction) internal pure {
        if (_auction.nft != address(0) && !_auction.called) {
            revert ItemIsAlreadyAuctioned(_auction);
        }
    }

    modifier nonAuctioned(AuctionNFT memory _auction) {
        beforeNonAuctioned(_auction);
        _;
    }

    function beforeOnlyAuctionCreator(
        AuctionNFT memory _auction,
        address _sender
    ) internal pure {
        if (_auction.creator != _sender) {
            revert NotAuctionCreator(_auction, _sender);
        }
    }

    modifier onlyAuctionCreator(AuctionNFT memory _auction, address _sender) {
        beforeOnlyAuctionCreator(_auction, _sender);
        _;
    }

    function beforeNonBiddedAuction(AuctionNFT memory _auction) internal pure {
        if (_auction.lastBidder != address(0)) {
            revert AuctionHasBidders(_auction);
        }
    }

    modifier nonBiddedAuction(AuctionNFT memory _auction) {
        beforeNonBiddedAuction(_auction);
        _;
    }

    function beforeOnlyAuthorisedAuctionCaller(
        AuctionNFT memory _auction,
        address _marketplaceOwner,
        address _sender
    ) internal pure {
        if (
            _sender != _marketplaceOwner &&
            _sender != _auction.creator &&
            _sender != _auction.lastBidder
        ) {
            revert notAuthorisedToCallAuction(
                _sender,
                _marketplaceOwner,
                _auction.creator,
                _auction.lastBidder
            );
        }
    }

    modifier onlyAuthorisedAuctionCaller(
        AuctionNFT memory _auction,
        address _marketplaceOwner,
        address _sender
    ) {
        beforeOnlyAuthorisedAuctionCaller(_auction, _marketplaceOwner, _sender);
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

    function beforeOnlyNFTOffer(OfferNFT memory _offer) internal pure {
        //TODO: Move to storage contract
        if (_offer.offerPrice <= 0 || _offer.offerer == address(0)) {
            revert ItemIsNotOffered(_offer);
        }
    }

    modifier onlyNFTOffer(OfferNFT memory _offer) {
        beforeOnlyNFTOffer(_offer);
        _;
    }

    function beforeOnlyNFTOfferOwner(OfferNFT memory _offer, address _sender)
        internal
        pure
    {
        if (_offer.offerer != _sender)
            revert NotOfferer(_offer.offerer, _sender);
    }

    modifier onlyNFTOfferOwner(OfferNFT memory _offer, address _sender) {
        beforeOnlyNFTOfferOwner(_offer, _sender);
        _;
    }

    function beforeNonAcceptedOffer(OfferNFT memory _offer, address _sender)
        internal
        pure
    {
        if (_offer.accepted) {
            revert OfferAlreadyAccepted(_offer.offerer, _sender);
        }
    }

    modifier nonAcceptedOffer(OfferNFT memory _offer, address _sender) {
        beforeNonAcceptedOffer(_offer, _sender);
        _;
    }

    //FIXME: make these pure
    function beforeOnlyPayableToken(bool _exists) internal pure {
        //     TODO: Move to storage contract
        //FIXME: determine if zero check is needed
        // if (_payToken == address(0)) {
        //     revert AddressIsZero(_payToken);
        // }
        if (!_exists) {
            revert NotValidPaymentToken();
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
            revert PaymentTokenAlreadyExists(_payToken);
        }
    }

    modifier nonPayableToken(bool _exists, address _payToken) {
        beforeNonPayableToken(_exists, _payToken);
        _;
    }
}
