// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.17;

interface IAfricarareNFTFactory {
    function createNFTCollection(
        string memory _name,
        string memory _symbol,
        uint256 _royaltyFee
    ) external;

    function onlyAfricarareNFT(address _nft) external view returns (bool);
}
