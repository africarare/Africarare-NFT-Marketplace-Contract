// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.17;

import "@openzeppelin/contracts/interfaces/IERC2981.sol";

abstract contract IERC2981Support {
    // bytes4 private constant INTERFACE_ID_ERC2981 = type(IERC2981).interfaceId;
    bytes4 private constant INTERFACE_ID_ERC2981 = 0x2a55205a;

    function getIERC2981Royalty(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) public view returns (address receiver, uint256 amount) {
        if (IERC165(nftAddress).supportsInterface(INTERFACE_ID_ERC2981)) {
            (receiver, amount) = IERC2981(nftAddress).royaltyInfo(
                tokenId,
                price
            );
            return (receiver, amount);
        } else return (address(0), 0);
    }
}
