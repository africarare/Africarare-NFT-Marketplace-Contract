// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract MockERC1155WithRoyalties is ERC1155, ERC2981 {
    constructor() ERC721("AfriMock", "AFRI") {
        _setDefaultRoyalty(_msgSender(), 500);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }
}