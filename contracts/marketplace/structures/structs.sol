// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.7;

struct ListNFT {
    address nft;
    uint256 tokenId;
    address seller;
    address payToken;
    uint256 price;
    bool sold;
}

struct OfferNFT {
    address nft;
    uint256 tokenId;
    address offerer;
    address payToken;
    uint256 offerPrice;
    bool accepted;
}

struct AuctionNFT {
    address nft;
    uint256 tokenId;
    address creator;
    address payToken;
    uint256 initialPrice;
    uint256 minBid;
    uint256 startTime;
    uint256 endTime;
    address lastBidder;
    uint256 highestBid;
    address winner;
    bool success;
}
