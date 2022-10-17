// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.17;

interface IAfricarareNFT {
    function getRoyaltyFee() external view returns (uint256);

    function getRoyaltyRecipient() external view returns (address);
}
