// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.7;

import "../token/AfricarareNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/* Africarare NFT Factory
    Create new Africarare NFT collection
*/
contract AfricarareNFTFactory is Ownable{
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
            _msgSender(),
            _royaltyFee,
            _royaltyRecipient
        );
        nfts[_msgSender()].push(address(nft));
        africarareNFT[address(nft)] = true;
        emit CreatedNFTCollection(_msgSender(), address(nft), _name, _symbol);
    }

    function getOwnCollections(address sender)
        external
        view
        returns (address[] memory)
    {
        return nfts[sender];
    }

    function onlyAfricarareNFT(address _nft) external view returns (bool) {
        return africarareNFT[_nft];
    }
}
