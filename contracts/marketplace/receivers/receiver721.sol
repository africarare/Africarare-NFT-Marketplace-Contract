// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

abstract contract Receiver721 is IERC721ReceiverUpgradeable {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        returns (bool)
    {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    function supportERC721(address _nftAddress) internal view returns (bool) {
        return
            IERC165Upgradeable(_nftAddress).supportsInterface(
                type(IERC721Upgradeable).interfaceId
            );
    }
}
