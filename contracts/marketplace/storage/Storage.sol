// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

//TODO: Implement
contract MarketplaceStorage is AccessControlUpgradeable {
    bytes32 public constant STORAGE_ADMIN_ROLE =
        keccak256("STORAGE_ADMIN_ROLE");

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(STORAGE_ADMIN_ROLE, _msgSender());
    }

    /**
     * @dev Throws if called by any account other than admins.
     */
    modifier adminOnly() {
        require(
            hasRole(STORAGE_ADMIN_ROLE, _msgSender()),
            "Must have storage admin role"
        );
        _;
    }
}
