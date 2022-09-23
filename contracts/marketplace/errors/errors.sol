// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.7;

import "../structures/structs.sol";
//ERRORS
// Insufficient balance for transfer. Needed `required` but only `available` available.
// @param available balance available.
// @param required requested amount to transfer.
//zero checks
error AddressIsZero(address _address);
error ZeroAddress();
//payments
error PaymentTokenAlreadyExists(address paytoken);
error NotValidPaymentToken(address paytoken);
//fees & royalty
error NotAfricarareNFT(address nft);
error PlatformFeeExceedLimit(uint256 platformFee, uint256 requiredLessThan);
error RoyaltyMaxExceeded(uint256 given, uint256 max);
//owner
error NotNftOwner(address sender, address nftOwner);
//listing
error NotListedNft();
error NotListedNftOwner(ListNFT, address nftOwner);
error ItemIsSold(ListNFT);
error ItemIsAlreadyListed(ListNFT);
error ItemIsNotListed(address nft, uint256 tokenId);
error InsufficientBalanceForItem(ListNFT, uint256 required);
//offers
error NotOfferer(address offerer, address sender);
error OfferAlreadyAccepted(address offerer, address sender);
error OfferPriceTooLow(uint256 listPrice);
error ItemIsNotOffered(OfferNFT);
//auction
error ItemIsAlreadyAuctioned(AuctionNFT);
error NotValidAuctionDuration(uint256 startTime, uint256 endTime);
error AuctionIsCalled(AuctionNFT);
error AuctionIsNotCalled(AuctionNFT);
error AuctionIsFinished(AuctionNFT, uint256 blockTimestamp);
error AuctionIsNotFinished(AuctionNFT, uint256 blockTimestamp);
error AuctionIsStarted(AuctionNFT, uint256 blockTimestamp);
error AuctionIsNotStarted(AuctionNFT, uint256 blockTimestamp);
error AuctionHasBidders(address lastBidder);
error BidTooLow(uint256 bid, uint256 minBidPrice);
error NotAuctionCreator(address sender, address auctioncreator);
error notAuthorisedToCallAuction(
    address sender,
    address marketOwner,
    address nftCreator,
    address auctionWinner
);
//admin
error isLockedContract();
