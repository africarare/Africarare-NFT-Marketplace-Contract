// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

abstract contract SupportsInterface {
    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant INTERFACE_ID_ERC1155 = 0xd9b67a26;

    function isERC721(address _nftAddress) private view returns (bool) {
        return IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC721);
    }

    function isERC1155(address _nftAddress) private view returns (bool) {
        return IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC1155);
    }
}
