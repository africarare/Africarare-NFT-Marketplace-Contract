// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.4;

import "../token/AfricarareNFT.sol";

/* Africarare NFT Factory
    Create new Africarare NFT collection
*/
contract AfricarareNFTFactory {
    // owner address => nft list
    mapping(address => address[]) private nfts;

    mapping(address => bool) private africarareNFT;

    event CreatedNFTCollection(
        address creator,
        address nft,
        string name,
        string symbol
    );

    function createNFTCollection(
        string memory _name,
        string memory _symbol,
        uint256 _royaltyFee,
        address _royaltyRecipient
    ) external {
        AfricarareNFT nft = new AfricarareNFT(
            _name,
            _symbol,
            msg.sender,
            _royaltyFee,
            _royaltyRecipient
        );
        nfts[msg.sender].push(address(nft));
        africarareNFT[address(nft)] = true;
        emit CreatedNFTCollection(msg.sender, address(nft), _name, _symbol);
    }

    function getOwnCollections(address sender) external view returns (address[] memory) {
        return nfts[sender];
    }

    function isAfricarareNFT(address _nft) external view returns (bool) {
        return africarareNFT[_nft];
    }
}
