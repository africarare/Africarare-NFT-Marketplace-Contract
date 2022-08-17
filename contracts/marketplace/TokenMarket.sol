// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity ^0.8.9;

import "../tokens/TokenAsset721.sol";
import "../tokens/TokenAsset.sol";
import "../storage/Storage.sol";
import "../utils/errors.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract TokenMarket is Pausable, Ownable, AccessControlEnumerable {
    bytes32 public constant MARKET_ADMIN_ROLE = keccak256("MARKET_ADMIN_ROLE");

    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant INTERFACE_ID_ERC1155 = 0xd9b67a26;

    uint256 public maxRoyalty;

    address public nftContractAddress;
    address public storageContractAddress;

    event TokenMinted(
        address nftAddress,
        uint256 tokenId,
        uint256 amount,
        address owner
    );
    event TokenListed(
        uint256 standard,
        address nftAddress,
        uint256 tokenId,
        uint256 itemId,
        uint256 amount,
        uint256 price,
        address owner
    );
    event TokenBought(
        uint256 standard,
        address nftAddress,
        uint256 tokenId,
        uint256 itemId,
        uint256 amount,
        uint256 price,
        address owner
    );
    event TokenUpdated(
        uint256 standard,
        address nftAddress,
        uint256 tokenId,
        uint256 itemId,
        uint256 price
    );

        event CreatedAuction(
        address indexed nft,
        uint256 indexed tokenId,
        address payToken,
        uint256 price,
        uint256 minBid,
        uint256 startTime,
        uint256 endTime,
        address indexed creator
    );

    event CancelledAuction(
        address indexed nft,
        uint256 indexed tokenId,
        uint256 endTime,
        address indexed creator
    );

    event PlacedBid(
        address indexed nft,
        uint256 indexed tokenId,
        address payToken,
        uint256 bidPrice,
        address indexed bidder
    );

    event ResultedAuction(
        address indexed nft,
        uint256 indexed tokenId,
        address creator,
        address indexed winner,
        uint256 price,
        address caller
    );


    TokenStorage private tokenStorage;

    constructor(
        uint256 _maxRoyalty,
        address _nftContractAddress,
        address _storageContractAddress
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MARKET_ADMIN_ROLE, _msgSender());

        maxRoyalty = _maxRoyalty;
        nftContractAddress = _nftContractAddress;
        storageContractAddress = _storageContractAddress;
        tokenStorage = TokenStorage(storageContractAddress);
    }

    function mintToken(
        uint256 _tokenId,
        uint256 _royalty,
        uint256 _amount
    ) public {
        require(_amount > 0, "Amount should be more than zero");
        require(_royalty <= maxRoyalty, "Royalty limit exceeded");

        require(
            !TokenStorage(storageContractAddress).isTokenMinted(
                nftContractAddress,
                _tokenId
            ),
            "Token is already minted"
        );

        TokenAsset(nftContractAddress).mint(
            _msgSender(),
            _tokenId,
            _amount,
            "0x"
        );

        tokenStorage.mintToken(
            nftContractAddress,
            _tokenId,
            _amount,
            _msgSender(),
            _royalty,
            block.timestamp
        );

        emit TokenMinted(nftContractAddress, _tokenId, _amount, _msgSender());
    }

    function createSale(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _price,
        uint256 _amount
    ) public {
        require(_amount > 0, "Amount should be more than zero");
        require(_price > 0, "Price must be greater than zero");

        uint256 _standard;
        uint256 _itemId;
        if (_supportERC721(_nftAddress)) {
            address owner = TokenAsset721(_nftAddress).ownerOf(_tokenId);
            require(owner == _msgSender(), "Caller is not owner");
            if (_amount > 1) {
                _amount = 1;
            }

            bool isApproved = TokenAsset721(_nftAddress).isApprovedForAll(
                _msgSender(),
                address(this)
            );
            require(isApproved, "Set approval before listing");
            _standard = 721;
        } else if (_supportERC1155(_nftAddress)) {
            uint256 balance = TokenAsset(_nftAddress).balanceOf(
                _msgSender(),
                _tokenId
            );
            require(balance >= _amount, "Must own enough token");

            bool isApproved = TokenAsset(_nftAddress).isApprovedForAll(
                _msgSender(),
                address(this)
            );
            require(isApproved, "Set approval before listing");
            _standard = 1155;
        } else {
            revert("Invalid nft address");
        }

        _itemId = tokenStorage.getTokenListingCount(_nftAddress, _tokenId) + 1;

        tokenStorage.listToken(
            _nftAddress,
            _tokenId,
            _itemId,
            _amount,
            _price,
            _msgSender(),
            _standard,
            block.timestamp
        );

        emit TokenListed(
            _standard,
            _nftAddress,
            _tokenId,
            _itemId,
            _amount,
            _price,
            _msgSender()
        );
    }

    function buyToken(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _itemId
    ) public payable {
        require(
            _itemId <= tokenStorage.getTokenListingCount(_nftAddress, _tokenId),
            "Item not found in market"
        );

        (
            uint256 price,
            uint256 amount,
            uint256 royalty,
            address owner,
            address creator,
            bool tradable,
            ,
            uint256 standard
        ) = tokenStorage.getListedToken(_nftAddress, _tokenId, _itemId);

        require(owner != address(0), "Token not found in listing");
        require(tradable, "Token is not tradable");
        require(owner != _msgSender(), "Cannot buy own token");
        if (msg.value < price) {
            revert InvalidPrice(msg.value, price);
        }



        if (_supportERC721(_nftAddress)) {
            address _owner = TokenAsset721(_nftAddress).ownerOf(_tokenId);
            if (_owner != owner) {
                revert("Token not owned by the seller");
            }
            TokenAsset721(_nftAddress).safeTransferFrom(
                owner,
                _msgSender(),
                _tokenId
            );
        } else if (_supportERC1155(_nftAddress)) {
            uint256 balance = TokenAsset(_nftAddress).balanceOf(
                owner,
                _tokenId
            );
            if (balance < amount) {
                revert("Not enough tokens available");
            }
            TokenAsset(_nftAddress).safeTransferFrom(
                owner,
                _msgSender(),
                _tokenId,
                amount,
                ""
            );
        } else {
            revert("Invalid nft address");
        }

        payPurchaseFee(payable(owner), payable(creator), msg.value, royalty);

        tokenStorage.buyToken(
            _nftAddress,
            _tokenId,
            _itemId,
            amount,
            price,
            owner,
            _msgSender(),
            block.timestamp
        );

        emit TokenBought(
            standard,
            _nftAddress,
            _tokenId,
            _itemId,
            amount,
            price,
            owner
        );
    }

    function payPurchaseFee(
        address payable _owner,
        address payable _creator,
        uint256 _value,
        uint256 _royalty
    ) private {
        address payable _platform = payable(tokenStorage.feeAddress());

        uint256 forCreator = _royalty != 0 ? ((_value * _royalty) / 100) : 0;
        uint256 forPlatform = ((_value * tokenStorage.platformFee()) / 100);
        uint256 forOwner = _value - forCreator - forPlatform;

        // Due to Stack too deep exception, calculations are done on the flow
        _owner.transfer(forOwner);
        _platform.transfer(forPlatform);
        if (forCreator != 0) {
            _creator.transfer(forCreator);
        }
    }

    function setMaxRoyalty(uint256 _newMaxRoyalty) public adminOnly {
        maxRoyalty = _newMaxRoyalty;
    }

    function _supportERC721(address _nftAddress) private view returns (bool) {
        return IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC721);
    }

    function _supportERC1155(address _nftAddress) private view returns (bool) {
        return IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC1155);
    }

    /**
     * @dev Throws if called by any account other than admins.
     */
    modifier adminOnly() {
        require(
            hasRole(MARKET_ADMIN_ROLE, _msgSender()),
            "#adminOnly: need admin role"
        );
        _;
    }
}
