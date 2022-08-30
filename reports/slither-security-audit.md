Summary
 - [tautology](#tautology) (1 results) (Medium)
 - [events-maths](#events-maths) (2 results) (Low)
 - [missing-zero-check](#missing-zero-check) (4 results) (Low)
 - [reentrancy-benign](#reentrancy-benign) (2 results) (Low)
 - [reentrancy-events](#reentrancy-events) (8 results) (Low)
 - [timestamp](#timestamp) (3 results) (Low)
 - [boolean-equal](#boolean-equal) (1 results) (Informational)
 - [dead-code](#dead-code) (2 results) (Informational)
 - [missing-inheritance](#missing-inheritance) (1 results) (Informational)
 - [unused-state](#unused-state) (1 results) (Informational)
 - [external-function](#external-function) (9 results) (Optimization)
## tautology
Impact: Medium
Confidence: High
 - [ ] ID-0
[AfricarareNFTMarketplace.offerNFT(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L328-L365) contains a tautology or contradiction:
	- [_offerPrice < 0](contracts/marketplace/AfricarareNFTMarketplace.sol#L336)

contracts/marketplace/AfricarareNFTMarketplace.sol#L328-L365


## events-maths
Impact: Low
Confidence: Medium
 - [ ] ID-1
[AfricarareNFT.updateRoyaltyFee(uint256)](contracts/token/AfricarareNFT.sol#L102-L108) should emit an event for:
	- [royaltyFee = _royaltyFee](contracts/token/AfricarareNFT.sol#L107)

contracts/token/AfricarareNFT.sol#L102-L108


 - [ ] ID-2
[AfricarareNFTMarketplace.updatePlatformFee(uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L798-L804) should emit an event for:
	- [platformFee = _platformFee](contracts/marketplace/AfricarareNFTMarketplace.sol#L803)

contracts/marketplace/AfricarareNFTMarketplace.sol#L798-L804


## missing-zero-check
Impact: Low
Confidence: Medium
 - [ ] ID-3
[TokenStorage.constructor(uint256,address)._feeAddress](contracts/storage/Storage.sol#L68) lacks a zero-check on :
		- [feeAddress = _feeAddress](contracts/storage/Storage.sol#L72)

contracts/storage/Storage.sol#L68


 - [ ] ID-4
[TokenStorage.setFeeAddress(address)._feeAddress](contracts/storage/Storage.sol#L220) lacks a zero-check on :
		- [feeAddress = _feeAddress](contracts/storage/Storage.sol#L221)

contracts/storage/Storage.sol#L220


 - [ ] ID-5
[AfricarareNFTMarketplace.constructor(uint256,address,IAfricarareNFTFactory)._feeRecipient](contracts/marketplace/AfricarareNFTMarketplace.sol#L89) lacks a zero-check on :
		- [feeRecipient = _feeRecipient](contracts/marketplace/AfricarareNFTMarketplace.sol#L95)

contracts/marketplace/AfricarareNFTMarketplace.sol#L89


 - [ ] ID-6
[AfricarareNFT.constructor(string,string,address,uint256,address)._royaltyRecipient](contracts/token/AfricarareNFT.sol#L38) lacks a zero-check on :
		- [royaltyRecipient = _royaltyRecipient](contracts/token/AfricarareNFT.sol#L44)

contracts/token/AfricarareNFT.sol#L38


## reentrancy-benign
Impact: Low
Confidence: Medium
 - [ ] ID-7
Reentrancy in [AfricarareNFTMarketplace.listNft(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L200-L224):
	External calls:
	- [nft.safeTransferFrom(msg.sender,address(this),_tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L212)
	State variables written after the call(s):
	- [listNfts[_nftAddress][_tokenId] = ListNFT(_nftAddress,_tokenId,msg.sender,_payToken,_price,false)](contracts/marketplace/AfricarareNFTMarketplace.sol#L215-L222)

contracts/marketplace/AfricarareNFTMarketplace.sol#L200-L224


 - [ ] ID-8
Reentrancy in [AfricarareNFTMarketplace.offerNFT(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L328-L365):
	External calls:
	- [IERC20(nft.payToken).safeTransferFrom(msg.sender,address(this),_offerPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L342-L346)
	State variables written after the call(s):
	- [offerNfts[_nftAddress][_tokenId][msg.sender] = OfferNFT(nft.nft,nft.tokenId,msg.sender,_payToken,_offerPrice,false)](contracts/marketplace/AfricarareNFTMarketplace.sol#L349-L356)

contracts/marketplace/AfricarareNFTMarketplace.sol#L328-L365


## reentrancy-events
Impact: Low
Confidence: Medium
 - [ ] ID-9
Reentrancy in [AfricarareNFTMarketplace.bidPlace(address,uint256,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L573-L649):
	External calls:
	- [payToken.safeTransferFrom(msg.sender,address(this),_bidPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L632)
	- [payToken.safeTransfer(lastBidder,lastBidPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L639)
	Event emitted after the call(s):
	- [PlacedBid(_nftAddress,_tokenId,auction.payToken,_bidPrice,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L642-L648)

contracts/marketplace/AfricarareNFTMarketplace.sol#L573-L649


 - [ ] ID-10
Reentrancy in [AfricarareNFTMarketplace.offerNFT(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L328-L365):
	External calls:
	- [IERC20(nft.payToken).safeTransferFrom(msg.sender,address(this),_offerPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L342-L346)
	Event emitted after the call(s):
	- [OfferedNFT(nft.nft,nft.tokenId,nft.payToken,_offerPrice,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L358-L364)

contracts/marketplace/AfricarareNFTMarketplace.sol#L328-L365


 - [ ] ID-11
Reentrancy in [AfricarareNFTMarketplace.resultAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L652-L738):
	External calls:
	- [payToken.safeTransfer(royaltyRecipient,royaltyTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L712)
	- [payToken.safeTransfer(feeRecipient,platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L718)
	- [payToken.safeTransfer(auction.creator,totalPrice - platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L721)
	- [nft.safeTransferFrom(address(this),auction.lastBidder,auction.tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L724-L728)
	Event emitted after the call(s):
	- [ResultedAuction(_nftAddress,_tokenId,auction.creator,auction.lastBidder,auction.highestBid,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L730-L737)

contracts/marketplace/AfricarareNFTMarketplace.sol#L652-L738


 - [ ] ID-12
Reentrancy in [AfricarareNFTMarketplace.cancelAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L534-L570):
	External calls:
	- [nft.safeTransferFrom(address(this),msg.sender,_tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L562)
	Event emitted after the call(s):
	- [CancelledAuction(_nftAddress,_tokenId,block.timestamp,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L563-L569)

contracts/marketplace/AfricarareNFTMarketplace.sol#L534-L570


 - [ ] ID-13
Reentrancy in [AfricarareNFTMarketplace.createAuction(address,uint256,address,uint256,uint256,uint256,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L481-L531):
	External calls:
	- [nft.safeTransferFrom(msg.sender,address(this),_tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L519)
	Event emitted after the call(s):
	- [CreatedAuction(_nftAddress,_tokenId,_payToken,_price,_minBid,_startTime,_endTime,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L521-L530)

contracts/marketplace/AfricarareNFTMarketplace.sol#L481-L531


 - [ ] ID-14
Reentrancy in [AfricarareNFTMarketplace.acceptOfferNFT(address,uint256,address)](contracts/marketplace/AfricarareNFTMarketplace.sol#L396-L478):
	External calls:
	- [payToken.safeTransfer(royaltyRecipient,royaltyTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L448)
	- [payToken.safeTransfer(feeRecipient,platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L454)
	- [payToken.safeTransfer(list.seller,offerPrice - platformFeeTotal - royaltyTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L458-L461)
	- [IERC721(list.nft).safeTransferFrom(address(this),offer.offerer,list.tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L464-L468)
	Event emitted after the call(s):
	- [AcceptedNFT(offer.nft,offer.tokenId,offer.payToken,offer.offerPrice,offer.offerer,list.seller)](contracts/marketplace/AfricarareNFTMarketplace.sol#L470-L477)

contracts/marketplace/AfricarareNFTMarketplace.sol#L396-L478


 - [ ] ID-15
Reentrancy in [AfricarareNFTMarketplace.cancelOfferNFT(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L368-L393):
	External calls:
	- [IERC20(offer.payToken).safeTransfer(offer.offerer,offer.offerPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L385)
	Event emitted after the call(s):
	- [CanceledOfferedNFT(offer.nft,offer.tokenId,offer.payToken,offer.offerPrice,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L386-L392)

contracts/marketplace/AfricarareNFTMarketplace.sol#L368-L393


 - [ ] ID-16
Reentrancy in [AfricarareNFTMarketplace.buyNFT(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L249-L326):
	External calls:
	- [IERC20(listedNft.payToken).safeTransferFrom(msg.sender,royaltyRecipient,royaltyTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L288-L292)
	- [IERC20(listedNft.payToken).safeTransferFrom(msg.sender,feeRecipient,platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L298-L302)
	- [IERC20(listedNft.payToken).safeTransferFrom(msg.sender,listedNft.seller,totalPrice - platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L305-L309)
	- [IERC721(listedNft.nft).safeTransferFrom(address(this),msg.sender,listedNft.tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L312-L316)
	Event emitted after the call(s):
	- [BoughtNFT(listedNft.nft,listedNft.tokenId,listedNft.payToken,_price,listedNft.seller,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L318-L325)

contracts/marketplace/AfricarareNFTMarketplace.sol#L249-L326


## timestamp
Impact: Low
Confidence: Medium
 - [ ] ID-17
[AfricarareNFTMarketplace.bidPlace(address,uint256,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L573-L649) uses timestamp for comparisons
	Dangerous comparisons:
	- [block.timestamp <= auctionNfts[_nftAddress][_tokenId].startTime](contracts/marketplace/AfricarareNFTMarketplace.sol#L585)
	- [block.timestamp >= auctionNfts[_nftAddress][_tokenId].endTime](contracts/marketplace/AfricarareNFTMarketplace.sol#L599)

contracts/marketplace/AfricarareNFTMarketplace.sol#L573-L649


 - [ ] ID-18
[AfricarareNFTMarketplace.resultAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L652-L738) uses timestamp for comparisons
	Dangerous comparisons:
	- [block.timestamp <= auctionNfts[_nftAddress][_tokenId].endTime](contracts/marketplace/AfricarareNFTMarketplace.sol#L679)
	- [block.timestamp < auctionNfts[_nftAddress][_tokenId].endTime](contracts/marketplace/AfricarareNFTMarketplace.sol#L690)

contracts/marketplace/AfricarareNFTMarketplace.sol#L652-L738


 - [ ] ID-19
[AfricarareNFTMarketplace.cancelAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L534-L570) uses timestamp for comparisons
	Dangerous comparisons:
	- [block.timestamp > auction.startTime](contracts/marketplace/AfricarareNFTMarketplace.sol#L549)

contracts/marketplace/AfricarareNFTMarketplace.sol#L534-L570


## boolean-equal
Impact: Informational
Confidence: High
 - [ ] ID-20
[AfricarareNFTMarketplace.isNotAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L157-L168) compares to a boolean constant:
	-[auction.nft != address(0) && auction.success == false](contracts/marketplace/AfricarareNFTMarketplace.sol#L164)

contracts/marketplace/AfricarareNFTMarketplace.sol#L157-L168


## dead-code
Impact: Informational
Confidence: Medium
 - [ ] ID-21
[SupportsInterface.isERC721(address)](contracts/marketplace/utils/supportsInterface.sol#L12-L14) is never used and should be removed

contracts/marketplace/utils/supportsInterface.sol#L12-L14


 - [ ] ID-22
[SupportsInterface.isERC1155(address)](contracts/marketplace/utils/supportsInterface.sol#L16-L18) is never used and should be removed

contracts/marketplace/utils/supportsInterface.sol#L16-L18


## missing-inheritance
Impact: Informational
Confidence: High
 - [ ] ID-23
[AfricarareNFT](contracts/token/AfricarareNFT.sol#L14-L140) should inherit from [IAfricarareNFT](contracts/marketplace/interfaces/IAfricarareNFT.sol#L5-L9)

contracts/token/AfricarareNFT.sol#L14-L140


## unused-state
Impact: Informational
Confidence: High
 - [ ] ID-24
[AfricarareNFTMarketplace.bidPrices](contracts/marketplace/AfricarareNFTMarketplace.sol#L84-L85) is never used in [AfricarareNFTMarketplace](contracts/marketplace/AfricarareNFTMarketplace.sol#L56-L814)

contracts/marketplace/AfricarareNFTMarketplace.sol#L84-L85


## external-function
Impact: Optimization
Confidence: High
 - [ ] ID-25
safeMint(address,string) should be declared external:
	- [AfricarareNFT.safeMint(address,string)](contracts/token/AfricarareNFT.sol#L70-L75)

contracts/token/AfricarareNFT.sol#L70-L75


 - [ ] ID-26
isTokenMinted(address,uint256) should be declared external:
	- [TokenStorage.isTokenMinted(address,uint256)](contracts/storage/Storage.sol#L140-L150)

contracts/storage/Storage.sol#L140-L150


 - [ ] ID-27
getTokenListingCount(address,uint256) should be declared external:
	- [TokenStorage.getTokenListingCount(address,uint256)](contracts/storage/Storage.sol#L152-L158)

contracts/storage/Storage.sol#L152-L158


 - [ ] ID-28
getMintedToken(address,uint256) should be declared external:
	- [TokenStorage.getMintedToken(address,uint256)](contracts/storage/Storage.sol#L176-L182)

contracts/storage/Storage.sol#L176-L182


 - [ ] ID-29
getBoughtToken(address,uint256,uint256) should be declared external:
	- [TokenStorage.getBoughtToken(address,uint256,uint256)](contracts/storage/Storage.sol#L184-L190)

contracts/storage/Storage.sol#L184-L190


 - [ ] ID-30
getListedToken(address,uint256,uint256) should be declared external:
	- [TokenStorage.getListedToken(address,uint256,uint256)](contracts/storage/Storage.sol#L192-L218)

contracts/storage/Storage.sol#L192-L218


 - [ ] ID-31
getRoyalty(address,uint256) should be declared external:
	- [TokenStorage.getRoyalty(address,uint256)](contracts/storage/Storage.sol#L168-L174)

contracts/storage/Storage.sol#L168-L174


 - [ ] ID-32
getCreator(address,uint256) should be declared external:
	- [TokenStorage.getCreator(address,uint256)](contracts/storage/Storage.sol#L160-L166)

contracts/storage/Storage.sol#L160-L166


 - [ ] ID-33
getListedNFT(address,uint256) should be declared external:
	- [AfricarareNFTMarketplace.getListedNFT(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L757-L763)

contracts/marketplace/AfricarareNFTMarketplace.sol#L757-L763


