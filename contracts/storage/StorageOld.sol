// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

//TODO: Implement
contract TokenStorage is AccessControlUpgradeable {
    bytes32 public constant STORAGE_ADMIN_ROLE =
        keccak256("STORAGE_ADMIN_ROLE");

    struct MintedTokens {
        address nftAddress;
        uint256 tokenId;
        uint256 amount;
        address creator;
        uint256 royalty;
        uint256 standard;
        uint256 timestamp;
    }

    struct TokenListings {
        address nftAddress;
        uint256 tokenId;
        uint256 amount;
        uint256 price;
        address owner;
        bool tradable;
        uint256 standard;
        uint256 timestamp;
    }

    struct BoughtToken {
        address nftAddress;
        uint256 tokenId;
        uint256 itemId;
        uint256 amount;
        uint256 price;
        address owner;
        address buyer;
        uint256 timestamp;
    }

    struct AuctionToken {
        address nftAddress;
        uint256 tokenId;
        address creator;
        address payToken;
        uint256 initialPrice;
        uint256 minBid;
        uint256 startTime;
        uint256 endTime;
        address lastBidder;
        uint256 highestBid;
        address winner;
        bool called;
    }

    address public feeAddress;
    uint256 public platformFee;

    mapping(address => mapping(uint256 => uint256)) private tokenListingCount;
    mapping(address => mapping(uint256 => MintedTokens)) private mintedTokens;
    mapping(address => mapping(uint256 => mapping(uint256 => TokenListings)))
        private tokenlistings;
    mapping(address => mapping(uint256 => mapping(uint256 => BoughtToken)))
        private boughtTokens;

    constructor(uint256 _platformFee, address _feeAddress) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(STORAGE_ADMIN_ROLE, _msgSender());

        if (_feeAddress != address(0)) {
            feeAddress = _feeAddress;
        }
        platformFee = _platformFee;
    }

    //stores a minted a token (1155) from the market contract
    function mintToken(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _amount,
        address _creator,
        uint256 _royalty,
        uint256 _timestamp
    ) external onlyRole(STORAGE_ADMIN_ROLE) {
        mintedTokens[_nftAddress][_tokenId].nftAddress = _nftAddress;
        mintedTokens[_nftAddress][_tokenId].tokenId = _tokenId;
        mintedTokens[_nftAddress][_tokenId].amount = _amount;
        mintedTokens[_nftAddress][_tokenId].creator = _creator;
        mintedTokens[_nftAddress][_tokenId].royalty = _royalty;
        mintedTokens[_nftAddress][_tokenId].timestamp = _timestamp;
    }

    function listToken(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _itemId,
        uint256 _amount,
        uint256 _price,
        address _owner,
        uint256 _standard,
        uint256 _timestamp
    ) external onlyRole(STORAGE_ADMIN_ROLE) {
        tokenlistings[_nftAddress][_tokenId][_itemId].nftAddress = _nftAddress;
        tokenlistings[_nftAddress][_tokenId][_itemId].tokenId = _tokenId;
        tokenlistings[_nftAddress][_tokenId][_itemId].amount = _amount;
        tokenlistings[_nftAddress][_tokenId][_itemId].price = _price;
        tokenlistings[_nftAddress][_tokenId][_itemId].owner = _owner;
        tokenlistings[_nftAddress][_tokenId][_itemId].tradable = true;
        tokenlistings[_nftAddress][_tokenId][_itemId].standard = _standard;
        tokenlistings[_nftAddress][_tokenId][_itemId].timestamp = _timestamp;

        tokenListingCount[_nftAddress][_tokenId]++;
    }

    function buyToken(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _itemId,
        uint256 _amount,
        uint256 _price,
        address _owner,
        address _buyer,
        uint256 _timestamp
    ) external onlyRole(STORAGE_ADMIN_ROLE) {
        boughtTokens[_nftAddress][_tokenId][_itemId].nftAddress = _nftAddress;
        boughtTokens[_nftAddress][_tokenId][_itemId].tokenId = _tokenId;
        boughtTokens[_nftAddress][_tokenId][_itemId].itemId = _itemId;
        boughtTokens[_nftAddress][_tokenId][_itemId].amount = _amount;
        boughtTokens[_nftAddress][_tokenId][_itemId].price = _price;
        boughtTokens[_nftAddress][_tokenId][_itemId].owner = _owner;
        boughtTokens[_nftAddress][_tokenId][_itemId].buyer = _buyer;
        boughtTokens[_nftAddress][_tokenId][_itemId].timestamp = _timestamp;

        tokenlistings[_nftAddress][_tokenId][_itemId].amount -= _amount;
        if (tokenlistings[_nftAddress][_tokenId][_itemId].amount <= 0) {
            tokenlistings[_nftAddress][_tokenId][_itemId].tradable = false;
        }
    }

    function isTokenMinted(address _nftAddress, uint256 _tokenId)
        public
        view
        returns (bool available)
    {
        if (mintedTokens[_nftAddress][_tokenId].amount == 0) {
            return false;
        } else {
            return true;
        }
    }

    function getTokenListingCount(address _nftAddress, uint256 _tokenId)
        public
        view
        returns (uint256 itemId)
    {
        return tokenListingCount[_nftAddress][_tokenId];
    }

    function getCreator(address _nftAddress, uint256 _tokenId)
        public
        view
        returns (address creator)
    {
        return mintedTokens[_nftAddress][_tokenId].creator;
    }

    function getRoyalty(address _nftAddress, uint256 _tokenId)
        public
        view
        returns (uint256 royalty)
    {
        return mintedTokens[_nftAddress][_tokenId].royalty;
    }

    function getMintedToken(address _nftAddress, uint256 _tokenId)
        public
        view
        returns (MintedTokens memory)
    {
        return mintedTokens[_nftAddress][_tokenId];
    }

    function getBoughtToken(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _itemId
    ) public view returns (BoughtToken memory) {
        return boughtTokens[_nftAddress][_tokenId][_itemId];
    }

    function getListedToken(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _itemId
    )
        public
        view
        returns (
            uint256 price,
            uint256 amount,
            uint256 royalty,
            address owner,
            address creator,
            bool tradable,
            uint256 timestamp,
            uint256 standard
        )
    {
        royalty = mintedTokens[_nftAddress][_tokenId].royalty | 0;
        creator = mintedTokens[_nftAddress][_tokenId].creator;
        standard = tokenlistings[_nftAddress][_tokenId][_itemId].standard;
        owner = tokenlistings[_nftAddress][_tokenId][_itemId].owner;
        price = tokenlistings[_nftAddress][_tokenId][_itemId].price;
        amount = tokenlistings[_nftAddress][_tokenId][_itemId].amount;
        tradable = tokenlistings[_nftAddress][_tokenId][_itemId].tradable;
        timestamp = tokenlistings[_nftAddress][_tokenId][_itemId].timestamp;
    }

    function setFeeAddress(address _feeAddress) external adminOnly {
        if (_feeAddress != address(0)) {
            feeAddress = _feeAddress;
        }
    }

    function setPlatformFee(uint256 _newPlatformFee) external adminOnly {
        platformFee = _newPlatformFee;
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
