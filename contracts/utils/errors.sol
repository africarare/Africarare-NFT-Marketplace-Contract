// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity ^0.8.9;

//ERRORS
//Incorrect amount of tokens sent for asked price
// @param sent balance.
// @param required balance.
error InvalidPrice(uint256 sent, uint256 required);
error NotListedNft();
error PlatformFeeExceedLimit(uint256 platformFee, uint256 requiredLessThan);
error NotOfferer(address addressOfOfferer, address addressOfSender);
error ItemIsSold(address _nft, uint256 _tokenId);
error SellerIsZeroAddress(address _nft, uint256 _tokenId);
