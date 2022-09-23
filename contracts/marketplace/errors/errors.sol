// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.7;

import "../structures/structs.sol";
//ERRORS
// Insufficient balance for transfer. Needed `required` but only `available` available.
// @param available balance available.
// @param required requested amount to transfer.
error InsufficientBalance(uint256 available, uint256 required);
error NotListedNft();
error PlatformFeeExceedLimit(uint256 platformFee, uint256 requiredLessThan);
error NotOfferer(address offerer, address sender);
error OfferAlreadyAccepted(address offerer, address sender);
error ItemIsSold(ListNFT);
error AddressIsZero(address _address);
error NotAfricarareNFT(address nft);
error ItemIsAlreadyListed(ListNFT);
error ItemIsNotListed(address nft, uint256 tokenId);
error ItemIsAlreadyAuctioned(address nft, uint256 tokenId);
error AuctionsHasCompleted(AuctionNFT);
error ItemIsNotOffered(address nft, uint256 tokenId);
error NotNftOwner(address sender, address nftOwner);
error NotListedNftOwner(address sender, address nftOwner);
error OfferPriceTooLow(uint256 listPrice);
error NotValidAuctionDuration(uint256 startTime, uint256 endTime);
error PaymentTokenAlreadyExists(address paytoken);
error NotValidPaymentToken(address paytoken);
error AuctionIsComplete(address nft, uint256 tokenId);
error AuctionIsNotComplete(address nft, uint256 tokenId);
error AuctionHasStarted(uint256 blockTimestamp, uint256 auctionStartTime);
error AuctionHasNotStarted(uint256 blockTimestamp, uint256 auctionStartTime);
error AuctionHasBidders(address lastBidder);
error BidTooLow(uint256 bid, uint256 minBidPrice);
error NotAuctionCreator(address sender, address auctioncreator);
error notAuthorisedToCallAuction(
    address sender,
    address marketOwner,
    address nftCreator,
    address auctionWinner
);
error ZeroAddress();
error isLockedContract();
error RoyaltyMaxExceeded(uint256 given, uint256 max);
