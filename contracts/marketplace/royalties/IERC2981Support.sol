// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.17;

import {IERC2981Upgradeable} from "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import {IERC165Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

abstract contract IERC2981Support {
    // bytes4 private constant INTERFACE_ID_ERC2981 = type(IERC2981).interfaceId;
    bytes4 private constant INTERFACE_ID_ERC2981 = 0x2a55205a;

    function getIERC2981Royalty(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) public view returns (address receiver, uint256 amount) {
        if (
            IERC165Upgradeable(nftAddress).supportsInterface(
                INTERFACE_ID_ERC2981
            )
        ) {
            (receiver, amount) = IERC2981Upgradeable(nftAddress).royaltyInfo(
                tokenId,
                price
            );
            return (receiver, amount);
        } else return (address(0), 0);
    }
}
