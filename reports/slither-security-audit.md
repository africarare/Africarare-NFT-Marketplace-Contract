Summary
 - [missing-zero-check](#missing-zero-check) (1 results) (Low)
 - [reentrancy-benign](#reentrancy-benign) (2 results) (Low)
 - [reentrancy-events](#reentrancy-events) (8 results) (Low)
 - [timestamp](#timestamp) (3 results) (Low)
 - [boolean-equal](#boolean-equal) (1 results) (Informational)
 - [dead-code](#dead-code) (2 results) (Informational)
 - [missing-inheritance](#missing-inheritance) (1 results) (Informational)
 - [unused-state](#unused-state) (1 results) (Informational)
 - [external-function](#external-function) (9 results) (Optimization)
## missing-zero-check
Impact: Low
Confidence: Medium
 - [ ] ID-0
[AfricarareNFT.constructor(string,string,address,uint256,address)._royaltyRecipient](contracts/token/AfricarareNFT.sol#L37) lacks a zero-check on :
		- [royaltyRecipient = _royaltyRecipient](contracts/token/AfricarareNFT.sol#L43)

contracts/token/AfricarareNFT.sol#L37


## reentrancy-benign
Impact: Low
Confidence: Medium
 - [ ] ID-1
Reentrancy in [AfricarareNFTMarketplace.offerNFT(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L332-L369):
	External calls:
	- [IERC20(nft.payToken).safeTransferFrom(_msgSender(),address(this),_offerPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L346-L350)
	State variables written after the call(s):
	- [offerNfts[_nftAddress][_tokenId][_msgSender()] = OfferNFT(nft.nft,nft.tokenId,_msgSender(),_payToken,_offerPrice,false)](contracts/marketplace/AfricarareNFTMarketplace.sol#L353-L360)

contracts/marketplace/AfricarareNFTMarketplace.sol#L332-L369


 - [ ] ID-2
Reentrancy in [AfricarareNFTMarketplace.listNft(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L204-L228):
	External calls:
	- [nft.safeTransferFrom(_msgSender(),address(this),_tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L216)
	State variables written after the call(s):
	- [listNfts[_nftAddress][_tokenId] = ListNFT(_nftAddress,_tokenId,_msgSender(),_payToken,_price,false)](contracts/marketplace/AfricarareNFTMarketplace.sol#L219-L226)

contracts/marketplace/AfricarareNFTMarketplace.sol#L204-L228


## reentrancy-events
Impact: Low
Confidence: Medium
 - [ ] ID-3
Reentrancy in [AfricarareNFTMarketplace.buyNFT(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L253-L330):
	External calls:
	- [IERC20(listedNft.payToken).safeTransferFrom(_msgSender(),royaltyRecipient,royaltyTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L292-L296)
	- [IERC20(listedNft.payToken).safeTransferFrom(_msgSender(),feeRecipient,platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L302-L306)
	- [IERC20(listedNft.payToken).safeTransferFrom(_msgSender(),listedNft.seller,totalPrice - platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L309-L313)
	- [IERC721(listedNft.nft).safeTransferFrom(address(this),_msgSender(),listedNft.tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L316-L320)
	Event emitted after the call(s):
	- [BoughtNFT(listedNft.nft,listedNft.tokenId,listedNft.payToken,_price,listedNft.seller,_msgSender())](contracts/marketplace/AfricarareNFTMarketplace.sol#L322-L329)

contracts/marketplace/AfricarareNFTMarketplace.sol#L253-L330


 - [ ] ID-4
Reentrancy in [AfricarareNFTMarketplace.resultAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L656-L742):
	External calls:
	- [payToken.safeTransfer(royaltyRecipient,royaltyTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L716)
	- [payToken.safeTransfer(feeRecipient,platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L722)
	- [payToken.safeTransfer(auction.creator,totalPrice - platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L725)
	- [nft.safeTransferFrom(address(this),auction.lastBidder,auction.tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L728-L732)
	Event emitted after the call(s):
	- [ResultedAuction(_nftAddress,_tokenId,auction.creator,auction.lastBidder,auction.highestBid,_msgSender())](contracts/marketplace/AfricarareNFTMarketplace.sol#L734-L741)

contracts/marketplace/AfricarareNFTMarketplace.sol#L656-L742


 - [ ] ID-5
Reentrancy in [AfricarareNFTMarketplace.cancelOfferNFT(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L372-L397):
	External calls:
	- [IERC20(offer.payToken).safeTransfer(offer.offerer,offer.offerPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L389)
	Event emitted after the call(s):
	- [CanceledOfferedNFT(offer.nft,offer.tokenId,offer.payToken,offer.offerPrice,_msgSender())](contracts/marketplace/AfricarareNFTMarketplace.sol#L390-L396)

contracts/marketplace/AfricarareNFTMarketplace.sol#L372-L397


 - [ ] ID-6
Reentrancy in [AfricarareNFTMarketplace.createAuction(address,uint256,address,uint256,uint256,uint256,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L485-L535):
	External calls:
	- [nft.safeTransferFrom(_msgSender(),address(this),_tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L523)
	Event emitted after the call(s):
	- [CreatedAuction(_nftAddress,_tokenId,_payToken,_price,_minBid,_startTime,_endTime,_msgSender())](contracts/marketplace/AfricarareNFTMarketplace.sol#L525-L534)

contracts/marketplace/AfricarareNFTMarketplace.sol#L485-L535


 - [ ] ID-7
Reentrancy in [AfricarareNFTMarketplace.bidPlace(address,uint256,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L577-L653):
	External calls:
	- [payToken.safeTransferFrom(_msgSender(),address(this),_bidPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L636)
	- [payToken.safeTransfer(lastBidder,lastBidPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L643)
	Event emitted after the call(s):
	- [PlacedBid(_nftAddress,_tokenId,auction.payToken,_bidPrice,_msgSender())](contracts/marketplace/AfricarareNFTMarketplace.sol#L646-L652)

contracts/marketplace/AfricarareNFTMarketplace.sol#L577-L653


 - [ ] ID-8
Reentrancy in [AfricarareNFTMarketplace.cancelAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L538-L574):
	External calls:
	- [nft.safeTransferFrom(address(this),_msgSender(),_tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L566)
	Event emitted after the call(s):
	- [CancelledAuction(_nftAddress,_tokenId,block.timestamp,_msgSender())](contracts/marketplace/AfricarareNFTMarketplace.sol#L567-L573)

contracts/marketplace/AfricarareNFTMarketplace.sol#L538-L574


 - [ ] ID-9
Reentrancy in [AfricarareNFTMarketplace.acceptOfferNFT(address,uint256,address)](contracts/marketplace/AfricarareNFTMarketplace.sol#L400-L482):
	External calls:
	- [payToken.safeTransfer(royaltyRecipient,royaltyTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L452)
	- [payToken.safeTransfer(feeRecipient,platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L458)
	- [payToken.safeTransfer(list.seller,offerPrice - platformFeeTotal - royaltyTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L462-L465)
	- [IERC721(list.nft).safeTransferFrom(address(this),offer.offerer,list.tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L468-L472)
	Event emitted after the call(s):
	- [AcceptedNFT(offer.nft,offer.tokenId,offer.payToken,offer.offerPrice,offer.offerer,list.seller)](contracts/marketplace/AfricarareNFTMarketplace.sol#L474-L481)

contracts/marketplace/AfricarareNFTMarketplace.sol#L400-L482


 - [ ] ID-10
Reentrancy in [AfricarareNFTMarketplace.offerNFT(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L332-L369):
	External calls:
	- [IERC20(nft.payToken).safeTransferFrom(_msgSender(),address(this),_offerPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L346-L350)
	Event emitted after the call(s):
	- [OfferedNFT(nft.nft,nft.tokenId,nft.payToken,_offerPrice,_msgSender())](contracts/marketplace/AfricarareNFTMarketplace.sol#L362-L368)

contracts/marketplace/AfricarareNFTMarketplace.sol#L332-L369


## timestamp
Impact: Low
Confidence: Medium
 - [ ] ID-11
[AfricarareNFTMarketplace.cancelAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L538-L574) uses timestamp for comparisons
	Dangerous comparisons:
	- [block.timestamp > auction.startTime](contracts/marketplace/AfricarareNFTMarketplace.sol#L553)

contracts/marketplace/AfricarareNFTMarketplace.sol#L538-L574


 - [ ] ID-12
[AfricarareNFTMarketplace.bidPlace(address,uint256,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L577-L653) uses timestamp for comparisons
	Dangerous comparisons:
	- [block.timestamp <= auctionNfts[_nftAddress][_tokenId].startTime](contracts/marketplace/AfricarareNFTMarketplace.sol#L589)
	- [block.timestamp >= auctionNfts[_nftAddress][_tokenId].endTime](contracts/marketplace/AfricarareNFTMarketplace.sol#L603)

contracts/marketplace/AfricarareNFTMarketplace.sol#L577-L653


 - [ ] ID-13
[AfricarareNFTMarketplace.resultAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L656-L742) uses timestamp for comparisons
	Dangerous comparisons:
	- [block.timestamp <= auctionNfts[_nftAddress][_tokenId].endTime](contracts/marketplace/AfricarareNFTMarketplace.sol#L683)
	- [block.timestamp < auctionNfts[_nftAddress][_tokenId].endTime](contracts/marketplace/AfricarareNFTMarketplace.sol#L694)

contracts/marketplace/AfricarareNFTMarketplace.sol#L656-L742


## boolean-equal
Impact: Informational
Confidence: High
 - [ ] ID-14
[AfricarareNFTMarketplace.isNotAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L161-L172) compares to a boolean constant:
	-[auction.nft != address(0) && auction.called == false](contracts/marketplace/AfricarareNFTMarketplace.sol#L168)

contracts/marketplace/AfricarareNFTMarketplace.sol#L161-L172


## dead-code
Impact: Informational
Confidence: Medium
 - [ ] ID-15
[SupportsInterface.isERC721(address)](contracts/marketplace/utils/supportsInterface.sol#L12-L14) is never used and should be removed

contracts/marketplace/utils/supportsInterface.sol#L12-L14


 - [ ] ID-16
[SupportsInterface.isERC1155(address)](contracts/marketplace/utils/supportsInterface.sol#L16-L18) is never used and should be removed

contracts/marketplace/utils/supportsInterface.sol#L16-L18


## missing-inheritance
Impact: Informational
Confidence: High
 - [ ] ID-17
[AfricarareNFT](contracts/token/AfricarareNFT.sol#L16-L140) should inherit from [IAfricarareNFT](contracts/marketplace/interfaces/IAfricarareNFT.sol#L5-L9)

contracts/token/AfricarareNFT.sol#L16-L140


## unused-state
Impact: Informational
Confidence: High
 - [ ] ID-18
[AfricarareNFTMarketplace.bidPrices](contracts/marketplace/AfricarareNFTMarketplace.sol#L84-L85) is never used in [AfricarareNFTMarketplace](contracts/marketplace/AfricarareNFTMarketplace.sol#L56-L819)

contracts/marketplace/AfricarareNFTMarketplace.sol#L84-L85


## external-function
Impact: Optimization
Confidence: High
 - [ ] ID-19
safeMint(address,string) should be declared external:
	- [AfricarareNFT.safeMint(address,string)](contracts/token/AfricarareNFT.sol#L69-L74)

contracts/token/AfricarareNFT.sol#L69-L74


 - [ ] ID-20
isTokenMinted(address,uint256) should be declared external:
	- [TokenStorage.isTokenMinted(address,uint256)](contracts/storage/Storage.sol#L142-L152)

contracts/storage/Storage.sol#L142-L152


 - [ ] ID-21
getTokenListingCount(address,uint256) should be declared external:
	- [TokenStorage.getTokenListingCount(address,uint256)](contracts/storage/Storage.sol#L154-L160)

contracts/storage/Storage.sol#L154-L160


 - [ ] ID-22
getMintedToken(address,uint256) should be declared external:
	- [TokenStorage.getMintedToken(address,uint256)](contracts/storage/Storage.sol#L178-L184)

contracts/storage/Storage.sol#L178-L184


 - [ ] ID-23
getBoughtToken(address,uint256,uint256) should be declared external:
	- [TokenStorage.getBoughtToken(address,uint256,uint256)](contracts/storage/Storage.sol#L186-L192)

contracts/storage/Storage.sol#L186-L192


 - [ ] ID-24
getListedToken(address,uint256,uint256) should be declared external:
	- [TokenStorage.getListedToken(address,uint256,uint256)](contracts/storage/Storage.sol#L194-L220)

contracts/storage/Storage.sol#L194-L220


 - [ ] ID-25
getRoyalty(address,uint256) should be declared external:
	- [TokenStorage.getRoyalty(address,uint256)](contracts/storage/Storage.sol#L170-L176)

contracts/storage/Storage.sol#L170-L176


 - [ ] ID-26
getCreator(address,uint256) should be declared external:
	- [TokenStorage.getCreator(address,uint256)](contracts/storage/Storage.sol#L162-L168)

contracts/storage/Storage.sol#L162-L168


 - [ ] ID-27
getListedNFT(address,uint256) should be declared external:
	- [AfricarareNFTMarketplace.getListedNFT(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L761-L767)

contracts/marketplace/AfricarareNFTMarketplace.sol#L761-L767


