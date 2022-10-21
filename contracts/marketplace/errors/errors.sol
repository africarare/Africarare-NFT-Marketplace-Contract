// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.17;

import {MarketplaceStructs} from "../structures/MarketplaceStructs.sol";

//TODO: Document
// Insufficient balance for transfer. Needed `required` but only `available` available.
// @param available balance available.
// @param required requested amount to transfer.

//zero checks
error AddressIsZero(address _address);
error ZeroAddress();
//payments
error PaymentTokenAlreadyExists(address paytoken);
error NotValidPaymentToken();
//fees & royalty
error NotAfricarareNFT(address nft);
error PlatformFeeExceedLimit(uint256 platformFee, uint256 requiredLessThan);
error RoyaltyMaxExceeded(uint256 given, uint256 max);
//owner
error NotNftOwner(address nftOwner, address sender);
//listing
error NotListedNft();
error NotListedNftOwner(MarketplaceStructs.ListNFT, address sender);
error ItemIsSold(MarketplaceStructs.ListNFT);
error ItemIsAlreadyListed(MarketplaceStructs.ListNFT);
error ItemIsNotListed(address nft, uint256 tokenId);
error InsufficientBalanceForItem(MarketplaceStructs.ListNFT, uint256 required);
//offers
error NotOfferer(address offerer, address sender);
error OfferAlreadyAccepted(address offerer, address sender);
error OfferPriceTooLow(uint256 listPrice);
error ItemIsNotOffered(MarketplaceStructs.OfferNFT);
//auction
error ItemIsAlreadyAuctioned(MarketplaceStructs.AuctionNFT);
error NotValidAuctionDuration(uint256 startTime, uint256 endTime);
error AuctionIsCalled(MarketplaceStructs.AuctionNFT);
error AuctionIsNotCalled(MarketplaceStructs.AuctionNFT);
error AuctionIsFinished(MarketplaceStructs.AuctionNFT, uint256 blockTimestamp);
error AuctionIsNotFinished(MarketplaceStructs.AuctionNFT, uint256 blockTimestamp);
error AuctionIsStarted(MarketplaceStructs.AuctionNFT, uint256 blockTimestamp);
error AuctionIsNotStarted(MarketplaceStructs.AuctionNFT, uint256 blockTimestamp);
error AuctionHasBidders(MarketplaceStructs.AuctionNFT);
error BidTooLow(uint256 bid, uint256 minBidPrice);
error NotAuctionCreator(MarketplaceStructs.AuctionNFT, address sender);
error notAuthorisedToCallAuction(
    address sender,
    address marketOwner,
    address nftCreator,
    address auctionWinner
);
//admin
error isLockedContract();
