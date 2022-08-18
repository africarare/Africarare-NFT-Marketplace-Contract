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
[AfricarareNFT.updateRoyaltyFee(uint256)](contracts/token/AfricarareNFT.sol#L72-L75) should emit an event for: 
	- [royaltyFee = _royaltyFee](contracts/token/AfricarareNFT.sol#L74) 

contracts/token/AfricarareNFT.sol#L72-L75


 - [ ] ID-1
[AfricarareNFTMarketplace.updatePlatformFee(uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L579-L582) should emit an event for: 
	- [platformFee = _platformFee](contracts/marketplace/AfricarareNFTMarketplace.sol#L581) 

contracts/marketplace/AfricarareNFTMarketplace.sol#L579-L582


## missing-zero-check
Impact: Low
Confidence: Medium
 - [ ] ID-2
[AfricarareNFTMarketplace.constructor(uint256,address,IAfricarareNFTFactory)._feeRecipient](contracts/marketplace/AfricarareNFTMarketplace.sol#L66) lacks a zero-check on :
		- [feeRecipient = _feeRecipient](contracts/marketplace/AfricarareNFTMarketplace.sol#L72)

contracts/marketplace/AfricarareNFTMarketplace.sol#L66


## reentrancy-benign
Impact: Low
Confidence: Medium
 - [ ] ID-3
Reentrancy in [AfricarareNFTMarketplace.listNft(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L161-L181):
	External calls:
	- [nft.safeTransferFrom(msg.sender,address(this),_tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L169)
	State variables written after the call(s):
	- [listNfts[_nftAddress][_tokenId] = ListNFT(_nftAddress,_tokenId,msg.sender,_payToken,_price,false)](contracts/marketplace/AfricarareNFTMarketplace.sol#L171-L178)

contracts/marketplace/AfricarareNFTMarketplace.sol#L161-L181


 - [ ] ID-4
Reentrancy in [AfricarareNFTMarketplace.offerNFT(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L260-L291):
	External calls:
	- [IERC20(nft.payToken).safeTransferFrom(msg.sender,address(this),_offerPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L269-L273)
	State variables written after the call(s):
	- [offerNfts[_nftAddress][_tokenId][msg.sender] = OfferNFT(nft.nft,nft.tokenId,msg.sender,_payToken,_offerPrice,false)](contracts/marketplace/AfricarareNFTMarketplace.sol#L275-L282)

contracts/marketplace/AfricarareNFTMarketplace.sol#L260-L291


## reentrancy-events
Impact: Low
Confidence: Medium
 - [ ] ID-5
Reentrancy in [AfricarareNFTMarketplace.cancelAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L423-L436):
	External calls:
	- [nft.safeTransferFrom(address(this),msg.sender,_tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L434)
	Event emitted after the call(s):
	- [CancelledAuction(_nftAddress,_tokenId,block.timestamp,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L435)

contracts/marketplace/AfricarareNFTMarketplace.sol#L423-L436


 - [ ] ID-6
Reentrancy in [AfricarareNFTMarketplace.cancelOfferNFT(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L294-L312):
	External calls:
	- [IERC20(offer.payToken).safeTransfer(offer.offerer,offer.offerPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L304)
	Event emitted after the call(s):
	- [CanceledOfferedNFT(offer.nft,offer.tokenId,offer.payToken,offer.offerPrice,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L305-L311)

contracts/marketplace/AfricarareNFTMarketplace.sol#L294-L312


 - [ ] ID-7
Reentrancy in [AfricarareNFTMarketplace.listNft(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L161-L181):
	External calls:
	- [nft.safeTransferFrom(msg.sender,address(this),_tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L169)
	Event emitted after the call(s):
	- [ListedNFT(_nftAddress,_tokenId,_payToken,_price,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L180)

contracts/marketplace/AfricarareNFTMarketplace.sol#L161-L181


 - [ ] ID-8
Reentrancy in [AfricarareNFTMarketplace.resultAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L478-L534):
	External calls:
	- [payToken.safeTransfer(royaltyRecipient,royaltyTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L508)
	- [payToken.safeTransfer(feeRecipient,platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L514)
	- [payToken.safeTransfer(auction.creator,totalPrice - platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L517)
	- [nft.safeTransferFrom(address(this),auction.lastBidder,auction.tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L520-L524)
	Event emitted after the call(s):
	- [ResultedAuction(_nftAddress,_tokenId,auction.creator,auction.lastBidder,auction.highestBid,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L526-L533)

contracts/marketplace/AfricarareNFTMarketplace.sol#L478-L534


 - [ ] ID-9
Reentrancy in [AfricarareNFTMarketplace.offerNFT(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L260-L291):
	External calls:
	- [IERC20(nft.payToken).safeTransferFrom(msg.sender,address(this),_offerPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L269-L273)
	Event emitted after the call(s):
	- [OfferedNFT(nft.nft,nft.tokenId,nft.payToken,_offerPrice,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L284-L290)

contracts/marketplace/AfricarareNFTMarketplace.sol#L260-L291


 - [ ] ID-10
Reentrancy in [AfricarareNFTMarketplace.bidPlace(address,uint256,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L439-L475):
	External calls:
	- [payToken.safeTransferFrom(msg.sender,address(this),_bidPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L464)
	- [payToken.safeTransfer(lastBidder,lastBidPrice)](contracts/marketplace/AfricarareNFTMarketplace.sol#L471)
	Event emitted after the call(s):
	- [PlacedBid(_nftAddress,_tokenId,auction.payToken,_bidPrice,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L474)

contracts/marketplace/AfricarareNFTMarketplace.sol#L439-L475


 - [ ] ID-11
Reentrancy in [AfricarareNFTMarketplace.buyNFT(address,uint256,address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L195-L258):
	External calls:
	- [IERC20(listedNft.payToken).safeTransferFrom(msg.sender,royaltyRecipient,royaltyTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L220-L224)
	- [IERC20(listedNft.payToken).safeTransferFrom(msg.sender,feeRecipient,platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L230-L234)
	- [IERC20(listedNft.payToken).safeTransferFrom(msg.sender,listedNft.seller,totalPrice - platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L237-L241)
	- [IERC721(listedNft.nft).safeTransferFrom(address(this),msg.sender,listedNft.tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L244-L248)
	Event emitted after the call(s):
	- [BoughtNFT(listedNft.nft,listedNft.tokenId,listedNft.payToken,_price,listedNft.seller,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L250-L257)

contracts/marketplace/AfricarareNFTMarketplace.sol#L195-L258


 - [ ] ID-12
Reentrancy in [AfricarareNFTMarketplace.createAuction(address,uint256,address,uint256,uint256,uint256,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L380-L420):
	External calls:
	- [nft.safeTransferFrom(msg.sender,address(this),_tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L408)
	Event emitted after the call(s):
	- [CreatedAuction(_nftAddress,_tokenId,_payToken,_price,_minBid,_startTime,_endTime,msg.sender)](contracts/marketplace/AfricarareNFTMarketplace.sol#L410-L419)

contracts/marketplace/AfricarareNFTMarketplace.sol#L380-L420


 - [ ] ID-13
Reentrancy in [AfricarareNFTMarketplace.acceptOfferNFT(address,uint256,address)](contracts/marketplace/AfricarareNFTMarketplace.sol#L315-L377):
	External calls:
	- [payToken.safeTransfer(royaltyRecipient,royaltyTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L347)
	- [payToken.safeTransfer(feeRecipient,platformFeeTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L353)
	- [payToken.safeTransfer(list.seller,offerPrice - platformFeeTotal - royaltyTotal)](contracts/marketplace/AfricarareNFTMarketplace.sol#L357-L360)
	- [IERC721(list.nft).safeTransferFrom(address(this),offer.offerer,list.tokenId)](contracts/marketplace/AfricarareNFTMarketplace.sol#L363-L367)
	Event emitted after the call(s):
	- [AcceptedNFT(offer.nft,offer.tokenId,offer.payToken,offer.offerPrice,offer.offerer,list.seller)](contracts/marketplace/AfricarareNFTMarketplace.sol#L369-L376)

contracts/marketplace/AfricarareNFTMarketplace.sol#L315-L377


## timestamp
Impact: Low
Confidence: Medium
 - [ ] ID-14
[AfricarareNFTMarketplace.bidPlace(address,uint256,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L439-L475) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(block.timestamp >= auctionNfts[_nftAddress][_tokenId].startTime,auction not start)](contracts/marketplace/AfricarareNFTMarketplace.sol#L444-L447)
	- [require(bool,string)(block.timestamp <= auctionNfts[_nftAddress][_tokenId].endTime,auction ended)](contracts/marketplace/AfricarareNFTMarketplace.sol#L448-L451)

contracts/marketplace/AfricarareNFTMarketplace.sol#L439-L475


 - [ ] ID-15
[AfricarareNFTMarketplace.cancelAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L423-L436) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(block.timestamp < auction.startTime,auction already started)](contracts/marketplace/AfricarareNFTMarketplace.sol#L429)

contracts/marketplace/AfricarareNFTMarketplace.sol#L423-L436


 - [ ] ID-16
[AfricarareNFTMarketplace.resultAuction(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L478-L534) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(block.timestamp > auctionNfts[_nftAddress][_tokenId].endTime,auction not ended)](contracts/marketplace/AfricarareNFTMarketplace.sol#L486-L489)

contracts/marketplace/AfricarareNFTMarketplace.sol#L478-L534


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
[AfricarareNFTMarketplace.bidPrices](contracts/marketplace/AfricarareNFTMarketplace.sol#L61-L62) is never used in [AfricarareNFTMarketplace](contracts/marketplace/AfricarareNFTMarketplace.sol#L35-L588)

contracts/marketplace/AfricarareNFTMarketplace.sol#L61-L62


## external-function
Impact: Optimization
Confidence: High
 - [ ] ID-19
safeMint(address,string) should be declared external:
	- [AfricarareNFT.safeMint(address,string)](contracts/token/AfricarareNFT.sol#L39-L44)

contracts/token/AfricarareNFT.sol#L39-L44


 - [ ] ID-20
onERC721Received(address,address,uint256,bytes) should be declared external:
	- [AfricarareNFTMarketplace.onERC721Received(address,address,uint256,bytes)](contracts/marketplace/AfricarareNFTMarketplace.sol#L148-L158)

contracts/marketplace/AfricarareNFTMarketplace.sol#L148-L158


 - [ ] ID-21
getListedNFT(address,uint256) should be declared external:
	- [AfricarareNFTMarketplace.getListedNFT(address,uint256)](contracts/marketplace/AfricarareNFTMarketplace.sol#L552-L558)

contracts/marketplace/AfricarareNFTMarketplace.sol#L552-L558


