Summary
 - [events-maths](#events-maths) (2 results) (Low)
 - [missing-zero-check](#missing-zero-check) (1 results) (Low)
 - [reentrancy-benign](#reentrancy-benign) (2 results) (Low)
 - [reentrancy-events](#reentrancy-events) (9 results) (Low)
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
[AfricarareNFTMarketplace.constructor(uint256,address,IAfricarareNFTFactory)._feeRecipient](contracts/marketplace/AfricarareNFTMarketplace.sol#L158) lacks a zero-check on :
		- [feeRecipient = _feeRecipient](contracts/marketplace/AfricarareNFTMarketplace.sol#L164)

contracts/marketplace/AfricarareNFTMarketplace.sol#L158


## reentrancy-benign
Impact: Low
Confidence: Medium
 - [ ] ID-3
Reentrancy in [AfricarareNFTMarketplace.offerNFT(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L354-L385):
	External calls:
	- [IERC20(nft.payToken).safeTransferFrom(msg.sender,address(this),_offerPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L363-L367)
	State variables written after the call(s):
	- [offerNfts[_nft][_tokenId][msg.sender] = OfferNFT(nft.nft,nft.tokenId,msg.sender,_payToken,_offerPrice,false)](contracts/marketplace/AfricarareNFTMarketplace.sol#L369-L376)

contracts/marketplace/AfricarareNFTMarketplace.sol#L354-L385


 - [ ] ID-4
Reentrancy in [AfricarareNFTMarketplace.listNft(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L254-L274):
	External calls:
	- [nft.safeTransferFrom(msg.sender,address(this),_tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L262)
	State variables written after the call(s):
	- [listNfts[_nft][_tokenId] = ListNFT(_nft,_tokenId,msg.sender,_payToken,_price,false)](contracts/marketplace/AfricarareNFTMarketplace.sol#L264-L271)

contracts/marketplace/AfricarareNFTMarketplace.sol#L254-L274


## reentrancy-events
Impact: Low
Confidence: Medium
 - [ ] ID-5
Reentrancy in [AfricarareNFTMarketplace.bidPlace(address,uint256,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L533-L569):
	External calls:
	- [payToken.safeTransferFrom(msg.sender,address(this),_bidPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L558)
	- [payToken.safeTransfer(lastBidder,lastBidPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L565)
	Event emitted after the call(s):
	- [PlacedBid(_nft,_tokenId,auction.payToken,_bidPrice,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L568)

contracts/marketplace/AfricarareNFTMarketplace.sol#L533-L569


 - [ ] ID-6
Reentrancy in [AfricarareNFTMarketplace.acceptOfferNFT(address,uint256,address)](contracts/marketplace/AfricarareNFTMarketplace.sol#L409-L471):
	External calls:
	- [payToken.safeTransfer(royaltyRecipient,royaltyTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L441)
	- [payToken.safeTransfer(feeRecipient,platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L447)
	- [payToken.safeTransfer(list.seller,offerPrice - platformFeeTotal - royaltyTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L451-L454)
	- [IERC721(list.nft).safeTransferFrom(address(this),offer.offerer,list.tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L457-L461)
	Event emitted after the call(s):
	- [AcceptedNFT(offer.nft,offer.tokenId,offer.payToken,offer.offerPrice,offer.offerer,list.seller)](contracts/marketplace/AfricarareNFTMarketplace.sol#L463-L470)

contracts/marketplace/AfricarareNFTMarketplace.sol#L409-L471


 - [ ] ID-7
Reentrancy in [AfricarareNFTMarketplace.cancelOfferNFT(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L388-L406):
	External calls:
	- [IERC20(offer.payToken).safeTransfer(offer.offerer,offer.offerPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L398)
	Event emitted after the call(s):
	- [CanceledOfferedNFT(offer.nft,offer.tokenId,offer.payToken,offer.offerPrice,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L399-L405)

contracts/marketplace/AfricarareNFTMarketplace.sol#L388-L406


 - [ ] ID-8
Reentrancy in [AfricarareNFTMarketplace.createAuction(address,uint256,address,uint256,uint256,uint256,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L474-L514):
	External calls:
	- [nft.safeTransferFrom(msg.sender,address(this),_tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L502)
	Event emitted after the call(s):
	- [CreatedAuction(_nft,_tokenId,_payToken,_price,_minBid,_startTime,_endTime,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L504-L513)

contracts/marketplace/AfricarareNFTMarketplace.sol#L474-L514


 - [ ] ID-9
Reentrancy in [AfricarareNFTMarketplace.offerNFT(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L354-L385):
	External calls:
	- [IERC20(nft.payToken).safeTransferFrom(msg.sender,address(this),_offerPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L363-L367)
	Event emitted after the call(s):
	- [OfferedNFT(nft.nft,nft.tokenId,nft.payToken,_offerPrice,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L378-L384)

contracts/marketplace/AfricarareNFTMarketplace.sol#L354-L385


 - [ ] ID-10
Reentrancy in [AfricarareNFTMarketplace.resultAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L572-L628):
	External calls:
	- [payToken.safeTransfer(royaltyRecipient,royaltyTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L602)
	- [payToken.safeTransfer(feeRecipient,platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L608)
	- [payToken.safeTransfer(auction.creator,totalPrice - platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L611)
	- [nft.safeTransferFrom(address(this),auction.lastBidder,auction.tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L614-L618)
	Event emitted after the call(s):
	- [ResultedAuction(_nft,_tokenId,auction.creator,auction.lastBidder,auction.highestBid,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L620-L627)

contracts/marketplace/AfricarareNFTMarketplace.sol#L572-L628


 - [ ] ID-11
Reentrancy in [AfricarareNFTMarketplace.buyNFT(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L288-L351):
	External calls:
	- [IERC20(listedNft.payToken).safeTransferFrom(msg.sender,royaltyRecipient,royaltyTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L313-L317)
	- [IERC20(listedNft.payToken).safeTransferFrom(msg.sender,feeRecipient,platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L323-L327)
	- [IERC20(listedNft.payToken).safeTransferFrom(msg.sender,listedNft.seller,totalPrice - platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L330-L334)
	- [IERC721(listedNft.nft).safeTransferFrom(address(this),msg.sender,listedNft.tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L337-L341)
	Event emitted after the call(s):
	- [BoughtNFT(listedNft.nft,listedNft.tokenId,listedNft.payToken,_price,listedNft.seller,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L343-L350)

contracts/marketplace/AfricarareNFTMarketplace.sol#L288-L351


 - [ ] ID-12
Reentrancy in [AfricarareNFTMarketplace.listNft(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L254-L274):
	External calls:
	- [nft.safeTransferFrom(msg.sender,address(this),_tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L262)
	Event emitted after the call(s):
	- [ListedNFT(_nft,_tokenId,_payToken,_price,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L273)

contracts/marketplace/AfricarareNFTMarketplace.sol#L254-L274


 - [ ] ID-13
Reentrancy in [AfricarareNFTMarketplace.cancelAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L517-L530):
	External calls:
	- [nft.safeTransferFrom(address(this),msg.sender,_tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L528)
	Event emitted after the call(s):
	- [CancelledAuction(_nft,_tokenId,block.timestamp,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L529)

contracts/marketplace/AfricarareNFTMarketplace.sol#L517-L530


## timestamp
Impact: Low
Confidence: Medium
 - [ ] ID-14
[AfricarareNFTMarketplace.bidPlace(address,uint256,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L533-L569) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(block.timestamp >= auctionNfts[_nft][_tokenId].startTime,auction not start)](contracts/marketplace/AfricarareNFTMarketplace.sol#L538-L541)
	- [require(bool,string)(block.timestamp <= auctionNfts[_nft][_tokenId].endTime,auction ended)](contracts/marketplace/AfricarareNFTMarketplace.sol#L542-L545)

contracts/marketplace/AfricarareNFTMarketplace.sol#L533-L569


 - [ ] ID-15
[AfricarareNFTMarketplace.resultAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L572-L628) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(block.timestamp > auctionNfts[_nft][_tokenId].endTime,auction not ended)](contracts/marketplace/AfricarareNFTMarketplace.sol#L580-L583)

contracts/marketplace/AfricarareNFTMarketplace.sol#L572-L628


 - [ ] ID-16
[AfricarareNFTMarketplace.cancelAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L517-L530) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(block.timestamp < auction.startTime,auction already started)](contracts/marketplace/AfricarareNFTMarketplace.sol#L523)

contracts/marketplace/AfricarareNFTMarketplace.sol#L517-L530


## missing-inheritance
Impact: Informational
Confidence: High
 - [ ] ID-17
[AfricarareNFT](contracts/token/AfricarareNFT.sol#L12-L76) should inherit from [IAfricarareNFT](contracts/marketplace/interfaces/IAfricarareNFT.sol#L5-L8)

contracts/token/AfricarareNFT.sol#L12-L76


## unused-state
Impact: Informational
Confidence: High
 - [ ] ID-18
[AfricarareNFTMarketplace.bidPrices](contracts/marketplace/AfricarareNFTMarketplace.sol#L80-L81) is never used in [AfricarareNFTMarketplace](contracts/marketplace/AfricarareNFTMarketplace.sol#L26-L682)

contracts/marketplace/AfricarareNFTMarketplace.sol#L80-L81


## external-function
Impact: Optimization
Confidence: High
 - [ ] ID-19
safeMint(address,string) should be declared external:
	- [AfricarareNFT.safeMint(address,string)](contracts/token/AfricarareNFT.sol#L39-L44)

contracts/token/AfricarareNFT.sol#L39-L44


 - [ ] ID-20
onERC721Received(address,address,uint256,bytes) should be declared external:
	- [AfricarareNFTMarketplace.onERC721Received(address,address,uint256,bytes)](contracts/marketplace/AfricarareNFTMarketplace.sol#L241-L251)

contracts/marketplace/AfricarareNFTMarketplace.sol#L241-L251


 - [ ] ID-21
getListedNFT(address,uint256) should be declared external:
	- [AfricarareNFTMarketplace.getListedNFT(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L646-L652)

contracts/marketplace/AfricarareNFTMarketplace.sol#L646-L652


