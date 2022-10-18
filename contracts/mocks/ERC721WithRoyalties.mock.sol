// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockERC721WithRoyalties is ERC721, ERC2981 {
    constructor() ERC721("AfriMock", "AFRI") {
        // set royalty of all NFTs to 5%
        //default basis points is 10000 (100%)
        //500/10000 = 5%
        _setDefaultRoyalty(_msgSender(), 500);
    }

    function mint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
