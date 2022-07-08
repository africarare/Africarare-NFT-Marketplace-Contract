Summary
 - [events-maths](#events-maths) (2 results) (Low)
 - [missing-zero-check](#missing-zero-check) (1 results) (Low)
 - [reentrancy-benign](#reentrancy-benign) (2 results) (Low)
 - [reentrancy-events](#reentrancy-events) (8 results) (Low)
 - [timestamp](#timestamp) (3 results) (Low)
 - [missing-inheritance](#missing-inheritance) (1 results) (Informational)
 - [unused-state](#unused-state) (1 results) (Informational)
 - [external-function](#external-function) (3 results) (Optimization)
## events-maths
Impact: Low
Confidence: Medium
 - [ ] ID-0
[AfricarareNFTMarketplace.updatePlatformFee(uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L673-L676) should emit an event for: 
	- [platformFee = _platformFee](contracts/marketplace/AfricarareNFTMarketplace.sol#L675) 

contracts/marketplace/AfricarareNFTMarketplace.sol#L673-L676


 - [ ] ID-1
[AfricarareNFT.updateRoyaltyFee(uint256)](contracts/token/AfricarareNFT.sol#L72-L75) should emit an event for: 
	- [royaltyFee = _royaltyFee](contracts/token/AfricarareNFT.sol#L74) 

contracts/token/AfricarareNFT.sol#L72-L75


## missing-zero-check
Impact: Low
Confidence: Medium
 - [ ] ID-2
[AfricarareNFTMarketplace.constructor(uint256,address,IAfricarareNFTFactory)._feeRecipient](contracts/marketplace/AfricarareNFTMarketplace.sol#L169) lacks a zero-check on :
		- [feeRecipient = _feeRecipient](contracts/marketplace/AfricarareNFTMarketplace.sol#L174)

contracts/marketplace/AfricarareNFTMarketplace.sol#L169


## reentrancy-benign
Impact: Low
Confidence: Medium
 - [ ] ID-3
Reentrancy in [AfricarareNFTMarketplace.offerNFT(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L360-L391):
	External calls:
	- [IERC20(nft.payToken).safeTransferFrom(msg.sender,address(this),_offerPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L369-L373)
	State variables written after the call(s):
	- [offerNfts[_nft][_tokenId][msg.sender] = OfferNFT(nft.nft,nft.tokenId,msg.sender,_payToken,_offerPrice,false)](contracts/marketplace/AfricarareNFTMarketplace.sol#L375-L382)

contracts/marketplace/AfricarareNFTMarketplace.sol#L360-L391


 - [ ] ID-4
Reentrancy in [AfricarareNFTMarketplace.listNft(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L260-L280):
	External calls:
	- [nft.safeTransferFrom(msg.sender,address(this),_tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L268)
	State variables written after the call(s):
	- [listNfts[_nft][_tokenId] = ListNFT(_nft,_tokenId,msg.sender,_payToken,_price,false)](contracts/marketplace/AfricarareNFTMarketplace.sol#L270-L277)

contracts/marketplace/AfricarareNFTMarketplace.sol#L260-L280


## reentrancy-events
Impact: Low
Confidence: Medium
 - [ ] ID-5
Reentrancy in [AfricarareNFTMarketplace.acceptOfferNFT(address,uint256,address)](contracts/marketplace/AfricarareNFTMarketplace.sol#L413-L473):
	External calls:
	- [payToken.safeTransfer(royaltyRecipient,royaltyTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L447)
	- [payToken.safeTransfer(feeRecipient,platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L453)
	- [payToken.safeTransfer(list.seller,totalPrice - platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L456)
	- [IERC721(list.nft).safeTransferFrom(address(this),offer.offerer,list.tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L459-L463)
	Event emitted after the call(s):
	- [AcceptedNFT(offer.nft,offer.tokenId,offer.payToken,offer.offerPrice,offer.offerer,list.seller)](contracts/marketplace/AfricarareNFTMarketplace.sol#L465-L472)

contracts/marketplace/AfricarareNFTMarketplace.sol#L413-L473


 - [ ] ID-6
Reentrancy in [AfricarareNFTMarketplace.resultAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L575-L628):
	External calls:
	- [payToken.safeTransfer(royaltyRecipient,royaltyTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L606)
	- [payToken.safeTransfer(feeRecipient,platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L612)
	- [payToken.safeTransfer(auction.creator,totalPrice - platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L615)
	- [nft.safeTransferFrom(address(this),auction.lastBidder,auction.tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L618)
	Event emitted after the call(s):
	- [ResultedAuction(_nft,_tokenId,auction.creator,auction.lastBidder,auction.highestBid,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L620-L627)

contracts/marketplace/AfricarareNFTMarketplace.sol#L575-L628


 - [ ] ID-7
Reentrancy in [AfricarareNFTMarketplace.cancelOfferNFT(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L394-L410):
	External calls:
	- [IERC20(offer.payToken).safeTransfer(offer.offerer,offer.offerPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L402)
	Event emitted after the call(s):
	- [CanceledOfferedNFT(offer.nft,offer.tokenId,offer.payToken,offer.offerPrice,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L403-L409)

contracts/marketplace/AfricarareNFTMarketplace.sol#L394-L410


 - [ ] ID-8
Reentrancy in [AfricarareNFTMarketplace.createAuction(address,uint256,address,uint256,uint256,uint256,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L476-L517):
	External calls:
	- [nft.safeTransferFrom(msg.sender,address(this),_tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L505)
	Event emitted after the call(s):
	- [CreatedAuction(_nft,_tokenId,_payToken,_price,_minBid,_startTime,_endTime,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L507-L516)

contracts/marketplace/AfricarareNFTMarketplace.sol#L476-L517


 - [ ] ID-9
Reentrancy in [AfricarareNFTMarketplace.buyNFT(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L294-L357):
	External calls:
	- [IERC20(listedNft.payToken).safeTransferFrom(msg.sender,royaltyRecipient,royaltyTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L319-L323)
	- [IERC20(listedNft.payToken).safeTransferFrom(msg.sender,feeRecipient,platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L329-L333)
	- [IERC20(listedNft.payToken).safeTransferFrom(msg.sender,listedNft.seller,totalPrice - platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L336-L340)
	- [IERC721(listedNft.nft).safeTransferFrom(address(this),msg.sender,listedNft.tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L343-L347)
	Event emitted after the call(s):
	- [BoughtNFT(listedNft.nft,listedNft.tokenId,listedNft.payToken,_price,listedNft.seller,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L349-L356)

contracts/marketplace/AfricarareNFTMarketplace.sol#L294-L357


 - [ ] ID-10
Reentrancy in [AfricarareNFTMarketplace.offerNFT(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L360-L391):
	External calls:
	- [IERC20(nft.payToken).safeTransferFrom(msg.sender,address(this),_offerPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L369-L373)
	Event emitted after the call(s):
	- [OfferedNFT(nft.nft,nft.tokenId,nft.payToken,_offerPrice,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L384-L390)

contracts/marketplace/AfricarareNFTMarketplace.sol#L360-L391


 - [ ] ID-11
Reentrancy in [AfricarareNFTMarketplace.listNft(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L260-L280):
	External calls:
	- [nft.safeTransferFrom(msg.sender,address(this),_tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L268)
	Event emitted after the call(s):
	- [ListedNFT(_nft,_tokenId,_payToken,_price,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L279)

contracts/marketplace/AfricarareNFTMarketplace.sol#L260-L280


 - [ ] ID-12
Reentrancy in [AfricarareNFTMarketplace.bidPlace(address,uint256,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L535-L572):
	External calls:
	- [payToken.safeTransferFrom(msg.sender,address(this),_bidPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L560)
	- [payToken.safeTransfer(lastBidder,lastBidPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L567)
	Event emitted after the call(s):
	- [PlacedBid(_nft,_tokenId,auction.payToken,_bidPrice,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L571)

contracts/marketplace/AfricarareNFTMarketplace.sol#L535-L572


## timestamp
Impact: Low
Confidence: Medium
 - [ ] ID-13
[AfricarareNFTMarketplace.cancelAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L520-L532) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(block.timestamp < auction.startTime,auction already started)](contracts/marketplace/AfricarareNFTMarketplace.sol#L526)

contracts/marketplace/AfricarareNFTMarketplace.sol#L520-L532


 - [ ] ID-14
[AfricarareNFTMarketplace.bidPlace(address,uint256,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L535-L572) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(block.timestamp >= auctionNfts[_nft][_tokenId].startTime,auction not start)](contracts/marketplace/AfricarareNFTMarketplace.sol#L540-L543)
	- [require(bool,string)(block.timestamp <= auctionNfts[_nft][_tokenId].endTime,auction ended)](contracts/marketplace/AfricarareNFTMarketplace.sol#L544-L547)

contracts/marketplace/AfricarareNFTMarketplace.sol#L535-L572


 - [ ] ID-15
[AfricarareNFTMarketplace.resultAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L575-L628) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(block.timestamp > auctionNfts[_nft][_tokenId].endTime,auction not ended)](contracts/marketplace/AfricarareNFTMarketplace.sol#L583-L586)

contracts/marketplace/AfricarareNFTMarketplace.sol#L575-L628


## missing-inheritance
Impact: Informational
Confidence: High
 - [ ] ID-16
[AfricarareNFT](contracts/token/AfricarareNFT.sol#L12-L76) should inherit from [IAfricarareNFT](contracts/marketplace/AfricarareNFTMarketplace.sol#L22-L25)

contracts/token/AfricarareNFT.sol#L12-L76


## unused-state
Impact: Informational
Confidence: High
 - [ ] ID-17
[AfricarareNFTMarketplace.bidPrices](contracts/marketplace/AfricarareNFTMarketplace.sol#L91-L92) is never used in [AfricarareNFTMarketplace](contracts/marketplace/AfricarareNFTMarketplace.sol#L37-L682)

contracts/marketplace/AfricarareNFTMarketplace.sol#L91-L92


## external-function
Impact: Optimization
Confidence: High
 - [ ] ID-18
safeMint(address,string) should be declared external:
	- [AfricarareNFT.safeMint(address,string)](contracts/token/AfricarareNFT.sol#L39-L44)

contracts/token/AfricarareNFT.sol#L39-L44


 - [ ] ID-19
onERC721Received(address,address,uint256,bytes) should be declared external:
	- [AfricarareNFTMarketplace.onERC721Received(address,address,uint256,bytes)](contracts/marketplace/AfricarareNFTMarketplace.sol#L245-L255)

contracts/marketplace/AfricarareNFTMarketplace.sol#L245-L255


 - [ ] ID-20
getListedNFT(address,uint256) should be declared external:
	- [AfricarareNFTMarketplace.getListedNFT(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L646-L652)

contracts/marketplace/AfricarareNFTMarketplace.sol#L646-L652


