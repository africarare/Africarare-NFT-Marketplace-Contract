// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity ^0.8.4;

//ERRORS
// Insufficient balance for transfer. Needed `required` but only `available` available.
// @param available balance available.
// @param required requested amount to transfer.
error InsufficientBalance(uint256 available, uint256 required);
error NotListedNft();
error PlatformFeeExceedLimit(uint256 platformFee, uint256 requiredLessThan);
error NotOfferer(address addressOfOfferer, address addressOfSender);
error ItemIsSold(address _nft, uint256 _tokenId);
error SellerIsZeroAddress(address _nft, uint256 _tokenId);
