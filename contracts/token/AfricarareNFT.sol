// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../registry/Proxy.sol";

/* Africarare NFT-ERC721 */
contract AfricarareNFT is
    ERC721,
    ERC721URIStorage,
    ERC721Burnable,
    Ownable,
    Pausable
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint256 private royaltyFee;
    address private royaltyRecipient;
    bool public lock;

    error ZeroAddress();
    error isLockedContract();
    error RoyaltyMaxExceeded(uint256 given, uint256 max);

    constructor(
        string memory _name,
        string memory _symbol,
        address _owner,
        uint256 _royaltyFee,
        address _royaltyRecipient
    ) ERC721(_name, _symbol) {
        _notExceedMaxRoyalty(_royaltyFee);
        _notZeroAddress(_owner);
        _notZeroAddress(_royaltyRecipient);
        royaltyFee = _royaltyFee;
        royaltyRecipient = _royaltyRecipient;
        transferOwnership(_owner);
    }

    function _notZeroAddress(address _address) internal pure {
        if (_address == address(0)) revert ZeroAddress();
    }

    function _notExceedMaxRoyalty(uint256 _royaltyFee) internal pure {
        if (_royaltyFee > 1000) revert RoyaltyMaxExceeded(_royaltyFee, 1000);
    }

    modifier notExceedMaxRoyalty(uint256 _royaltyFee) {
        _notExceedMaxRoyalty(_royaltyFee);
        _;
    }

    function _notLocked(bool _lock) internal pure {
        if (_lock) revert isLockedContract();
    }

    modifier notLocked(bool _lock) {
        _notLocked(_lock);
        _;
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
        notLocked(lock)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function getRoyaltyFee() external view returns (uint256) {
        return royaltyFee;
    }

    function getRoyaltyRecipient() external view returns (address) {
        return royaltyRecipient;
    }

    function updateRoyaltyFee(uint256 _royaltyFee)
        external
        onlyOwner
        notExceedMaxRoyalty(_royaltyFee)
    {
        royaltyFee = _royaltyFee;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function lockContract() external onlyOwner {
        lock = true;
    }
    /**
     * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-free listings.
     */
    //rinkeby
    // address private proxyRegistryAddress = 0x1E525EEAF261cA41b809884CBDE9DD9E1619573A;
    // function isApprovedForAll(address _owner, address _operator)
    //     public
    //     view
    //     override
    //     returns (bool isOperator)
    // {
    //     // Whitelist OpenSea proxy contract for easy trading.
    //     ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    //     if (address(proxyRegistry.proxies(_owner)) == _operator) {
    //         return true;
    //     }

    //     return ERC721.isApprovedForAll(_owner, _operator);
    // }
}
