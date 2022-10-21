// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockERC721 is ERC721, ERC721URIStorage, Ownable {
  constructor() ERC721("AfriMock", "AFRI") {}

  function mintToken(address receiverAddress, string memory tokenURI) public onlyOwner {
      _safeMint(receiverAddress, tokenURI);
  }
}