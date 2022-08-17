Summary
 - [uninitialized-local](#uninitialized-local) (1 results) (Medium)
 - [missing-zero-check](#missing-zero-check) (5 results) (Low)
 - [reentrancy-events](#reentrancy-events) (3 results) (Low)
 - [solc-version](#solc-version) (6 results) (Informational)
 - [reentrancy-unlimited-gas](#reentrancy-unlimited-gas) (1 results) (Informational)
 - [external-function](#external-function) (15 results) (Optimization)
## uninitialized-local
Impact: Medium
Confidence: Medium
 - [ ] ID-0
[TokenMarket.createSale(address,uint256,uint256,uint256)._standard](contracts/TokenMarket.sol#L151) is a local variable never initialized

contracts/TokenMarket.sol#L151


## missing-zero-check
Impact: Low
Confidence: Medium
 - [ ] ID-1
[TokenStorage.setFeeAddress(address)._feeAddress](contracts/Storage.sol#L219) lacks a zero-check on :
		- [feeAddress = _feeAddress](contracts/Storage.sol#L220)

contracts/Storage.sol#L219


 - [ ] ID-2
[TokenStorage.constructor(uint256,address)._feeAddress](contracts/Storage.sol#L68) lacks a zero-check on :
		- [feeAddress = _feeAddress](contracts/Storage.sol#L72)

contracts/Storage.sol#L68


 - [ ] ID-3
[TokenMarket.constructor(uint256,address,address)._storageContractAddress](contracts/TokenMarket.sol#L96) lacks a zero-check on :
		- [storageContractAddress = _storageContractAddress](contracts/TokenMarket.sol#L103)

contracts/TokenMarket.sol#L96


 - [ ] ID-4
[TokenMarket.constructor(uint256,address,address)._nftContractAddress](contracts/TokenMarket.sol#L95) lacks a zero-check on :
		- [nftContractAddress = _nftContractAddress](contracts/TokenMarket.sol#L102)

contracts/TokenMarket.sol#L95


 - [ ] ID-5
[TokenAsset721.constructor(address)._proxyRegistryAddress](contracts/TokenAsset721.sol#L19) lacks a zero-check on :
		- [proxyRegistryAddress = _proxyRegistryAddress](contracts/TokenAsset721.sol#L26)

contracts/TokenAsset721.sol#L19


## reentrancy-events
Impact: Low
Confidence: Medium
 - [ ] ID-6
Reentrancy in [TokenMarket.buyToken(address,uint256,uint256)](contracts/TokenMarket.sol#L207-L284):
	External calls:
	- [TokenAsset721(_nftAddress).safeTransferFrom(owner,_msgSender(),_tokenId)](contracts/TokenMarket.sol#L238-L242)
	- [TokenAsset(_nftAddress).safeTransferFrom(owner,_msgSender(),_tokenId,amount,)](contracts/TokenMarket.sol#L251-L257)
	- [tokenStorage.buyToken(_nftAddress,_tokenId,_itemId,amount,price,owner,_msgSender(),block.timestamp)](contracts/TokenMarket.sol#L264-L273)
	External calls sending eth:
	- [payPurchaseFee(address(owner),address(creator),msg.value,royalty)](contracts/TokenMarket.sol#L262)
		- [_owner.transfer(forOwner)](contracts/TokenMarket.sol#L299)
		- [_platform.transfer(forPlatform)](contracts/TokenMarket.sol#L300)
		- [_creator.transfer(forCreator)](contracts/TokenMarket.sol#L302)
	Event emitted after the call(s):
	- [TokenBought(standard,_nftAddress,_tokenId,_itemId,amount,price,owner)](contracts/TokenMarket.sol#L275-L283)

contracts/TokenMarket.sol#L207-L284


 - [ ] ID-7
Reentrancy in [TokenMarket.mintToken(uint256,uint256,uint256)](contracts/TokenMarket.sol#L107-L140):
	External calls:
	- [TokenAsset(nftContractAddress).mint(_msgSender(),_tokenId,_amount,0x)](contracts/TokenMarket.sol#L123-L128)
	- [tokenStorage.mintToken(nftContractAddress,_tokenId,_amount,_msgSender(),_royalty,block.timestamp)](contracts/TokenMarket.sol#L130-L137)
	Event emitted after the call(s):
	- [TokenMinted(nftContractAddress,_tokenId,_amount,_msgSender())](contracts/TokenMarket.sol#L139)

contracts/TokenMarket.sol#L107-L140


 - [ ] ID-8
Reentrancy in [TokenMarket.createSale(address,uint256,uint256,uint256)](contracts/TokenMarket.sol#L142-L205):
	External calls:
	- [tokenStorage.listToken(_nftAddress,_tokenId,_itemId,_amount,_price,_msgSender(),_standard,block.timestamp)](contracts/TokenMarket.sol#L185-L194)
	Event emitted after the call(s):
	- [TokenListed(_standard,_nftAddress,_tokenId,_itemId,_amount,_price,_msgSender())](contracts/TokenMarket.sol#L196-L204)

contracts/TokenMarket.sol#L142-L205


## solc-version
Impact: Informational
Confidence: High
 - [ ] ID-9
Pragma version[^0.8.9](contracts/Proxy.sol#L2) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.7

contracts/Proxy.sol#L2


 - [ ] ID-10
Pragma version[^0.8.9](contracts/TokenAsset.sol#L2) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.7

contracts/TokenAsset.sol#L2


 - [ ] ID-11
Pragma version[^0.8.9](contracts/TokenMarket.sol#L2) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.7

contracts/TokenMarket.sol#L2


 - [ ] ID-12
Pragma version[^0.8.9](contracts/Storage.sol#L2) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.7

contracts/Storage.sol#L2


 - [ ] ID-13
Pragma version[^0.8.9](contracts/TokenAsset721.sol#L2) necessitates a version too recent to be trusted. Consider deploying with 0.6.12/0.7.6/0.8.7

contracts/TokenAsset721.sol#L2


 - [ ] ID-14
solc-0.8.9 is not recommended for deployment

## reentrancy-unlimited-gas
Impact: Informational
Confidence: Medium
 - [ ] ID-15
Reentrancy in [TokenMarket.buyToken(address,uint256,uint256)](contracts/TokenMarket.sol#L207-L284):
	External calls:
	- [payPurchaseFee(address(owner),address(creator),msg.value,royalty)](contracts/TokenMarket.sol#L262)
		- [_owner.transfer(forOwner)](contracts/TokenMarket.sol#L299)
		- [_platform.transfer(forPlatform)](contracts/TokenMarket.sol#L300)
		- [_creator.transfer(forCreator)](contracts/TokenMarket.sol#L302)
	Event emitted after the call(s):
	- [TokenBought(standard,_nftAddress,_tokenId,_itemId,amount,price,owner)](contracts/TokenMarket.sol#L275-L283)

contracts/TokenMarket.sol#L207-L284


## external-function
Impact: Optimization
Confidence: High
 - [ ] ID-16
isTokenMinted(address,uint256) should be declared external:
	- [TokenStorage.isTokenMinted(address,uint256)](contracts/Storage.sol#L139-L149)

contracts/Storage.sol#L139-L149


 - [ ] ID-17
getTokenListingCount(address,uint256) should be declared external:
	- [TokenStorage.getTokenListingCount(address,uint256)](contracts/Storage.sol#L151-L157)

contracts/Storage.sol#L151-L157


 - [ ] ID-18
buyToken(address,uint256,uint256) should be declared external:
	- [TokenMarket.buyToken(address,uint256,uint256)](contracts/TokenMarket.sol#L207-L284)

contracts/TokenMarket.sol#L207-L284


 - [ ] ID-19
getMintedToken(address,uint256) should be declared external:
	- [TokenStorage.getMintedToken(address,uint256)](contracts/Storage.sol#L175-L181)

contracts/Storage.sol#L175-L181


 - [ ] ID-20
unpause() should be declared external:
	- [TokenAsset721.unpause()](contracts/TokenAsset721.sol#L44-L46)

contracts/TokenAsset721.sol#L44-L46


 - [ ] ID-21
setMaxRoyalty(uint256) should be declared external:
	- [TokenMarket.setMaxRoyalty(uint256)](contracts/TokenMarket.sol#L306-L308)

contracts/TokenMarket.sol#L306-L308


 - [ ] ID-22
mint(address,uint256) should be declared external:
	- [TokenAsset721.mint(address,uint256)](contracts/TokenAsset721.sol#L48-L50)

contracts/TokenAsset721.sol#L48-L50


 - [ ] ID-23
getBoughtToken(address,uint256,uint256) should be declared external:
	- [TokenStorage.getBoughtToken(address,uint256,uint256)](contracts/Storage.sol#L183-L189)

contracts/Storage.sol#L183-L189


 - [ ] ID-24
getListedToken(address,uint256,uint256) should be declared external:
	- [TokenStorage.getListedToken(address,uint256,uint256)](contracts/Storage.sol#L191-L217)

contracts/Storage.sol#L191-L217


 - [ ] ID-25
getRoyalty(address,uint256) should be declared external:
	- [TokenStorage.getRoyalty(address,uint256)](contracts/Storage.sol#L167-L173)

contracts/Storage.sol#L167-L173


 - [ ] ID-26
setURI(string) should be declared external:
	- [TokenAsset.setURI(string)](contracts/TokenAsset.sol#L46-L48)

contracts/TokenAsset.sol#L46-L48


 - [ ] ID-27
mintToken(uint256,uint256,uint256) should be declared external:
	- [TokenMarket.mintToken(uint256,uint256,uint256)](contracts/TokenMarket.sol#L107-L140)

contracts/TokenMarket.sol#L107-L140


 - [ ] ID-28
pause() should be declared external:
	- [TokenAsset721.pause()](contracts/TokenAsset721.sol#L40-L42)

contracts/TokenAsset721.sol#L40-L42


 - [ ] ID-29
getCreator(address,uint256) should be declared external:
	- [TokenStorage.getCreator(address,uint256)](contracts/Storage.sol#L159-L165)

contracts/Storage.sol#L159-L165


 - [ ] ID-30
setContractURI(string) should be declared external:
	- [TokenAsset.setContractURI(string)](contracts/TokenAsset.sol#L50-L55)

contracts/TokenAsset.sol#L50-L55


