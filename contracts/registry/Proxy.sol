// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity ^0.8.17;

//solhint-disable-next-line no-empty-blocks
contract OwnableDelegateProxy {

}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}
