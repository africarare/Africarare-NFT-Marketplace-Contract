// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity ^0.8.4;

interface IAfricarareNFTFactory {
    function createNFTCollection(
        string memory _name,
        string memory _symbol,
        uint256 _royaltyFee
    ) external;

    function isAfricarareNFT(address _nft) external view returns (bool);
}
