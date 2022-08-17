const {Min} = require("mocha/lib/reporters");

import {ethers} from "hardhat";
import {expect} from "chai";
import {utils} from "ethers"

describe("Market contract", function () {
    let TokenAsset;
    let TokenMarket;
    let TokenStorage;

    let tokenAsset: any;
    let tokenMarket: any;
    let tokenStorage: any;

    let owner: any;

    let user1: any
    let user2: any

    let MINTER_ROLE = utils.keccak256(
        utils.toUtf8Bytes("MINTER_ROLE")
    );
    let STORAGE_ADMIN_ROLE = utils.keccak256(
        utils.toUtf8Bytes("STORAGE_ADMIN_ROLE")
    );

    let chainId = "4";
    let maxRoyalty = 10;
    let platformFee = 10;
    let symbol = "AFRIMKT";
    let name = "Africarare NFT Marketplace";
    let platformAddress = "0x8441c8aa41c7D1b2DE94260D29fFbbd523acfaa9";

    // rinkeby
    let proxyRegistryAddress = "0x1E525EEAF261cA41b809884CBDE9DD9E1619573A";
    // mainnet
    // let proxyRegistryAddress = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";

    // `beforeEach` will run before each test, re-deploying the contract every time.
    // It receives a callback, which can be async.
    before(async function () {

        [owner, user1, user2] = await ethers.getSigners();
        let ownerBalance = await ethers.provider.getBalance(owner.address)
        console.log("Owner Address:", owner.address);
        console.log('Owner Balance:', ownerBalance.toString());

        TokenAsset = await ethers.getContractFactory("TokenAsset");
        TokenMarket = await ethers.getContractFactory("TokenMarket");
        TokenStorage = await ethers.getContractFactory("TokenStorage");

        tokenAsset = await TokenAsset.deploy(
            name,
            symbol,
            chainId
        );
        await tokenAsset.deployed();
        console.log(`Token Contract deployed at: ${tokenAsset.address}`);

        tokenStorage = await TokenStorage.deploy(
            platformFee,
            platformAddress
        );
        await tokenStorage.deployed();
        console.log(`Storage Contract deployed at: ${tokenStorage.address}`);

        tokenMarket = await TokenMarket.deploy(
            maxRoyalty,
            tokenAsset.address,
            tokenStorage.address
        );
        await tokenMarket.deployed();
    });

    // You can nest describe calls to create subsections.
    describe("Deployment", function () {
        describe("Asset Contract pre approvals", function () {
            it("Should check minter role in asset contract", async function () {
                expect(await tokenAsset.hasRole(MINTER_ROLE, tokenMarket.address)).to.equal(false);
            });

            it("Should able to grant minter role in asset contract", async function () {
                expect(await tokenAsset.grantRole(MINTER_ROLE, tokenMarket.address));
                expect(await tokenAsset.hasRole(MINTER_ROLE, tokenMarket.address)).to.equal(true);
            });

            it("Should able to get uri for token Id", async function () {
                let uri = await tokenAsset.uri(1);
                console.log(`TokenURI: ${uri}`);
            });
        });

        describe("Storage Contract", function () {
            it("Should check storage admin role", async function () {
                expect(await tokenStorage.hasRole(STORAGE_ADMIN_ROLE, tokenMarket.address)).to.equal(false);
            });

            it("Should able to grant storage admin role", async function () {
                expect(await tokenStorage.grantRole(STORAGE_ADMIN_ROLE, tokenMarket.address));
                expect(await tokenStorage.hasRole(STORAGE_ADMIN_ROLE, tokenMarket.address)).to.equal(true);
            });
        });

        describe("MarketContract", function () {
            it("Should check minter role in market", async function () {
                expect(await tokenMarket.owner()).to.equal(owner.address);
            });
            it("Should check max royalty is set properly", async function () {
                expect(await tokenMarket.maxRoyalty()).to.equal(maxRoyalty);
            });

            it("Should check nft contract address is set properly", async function () {
                expect(await tokenMarket.nftContractAddress()).to.equal(tokenAsset.address);
            });
            it("Should check storage contract address is set properly", async function () {
                expect(await tokenMarket.storageContractAddress()).to.equal(tokenStorage.address);
            });
        });
    });

    describe("Market public actions", async function () {

        let royalty = 10;
        let tokenId = 1000;
        let amount = 10;
        let tokenPrice = utils.parseEther("0.05");
        let parsedPrice = utils.parseUnits((0.05).toString());
        let currentTime = Date.now() / 1000;

        console.log(`TokenId: ${tokenId}`);
        console.log(`Royalty: ${royalty}`);

        it("Should able to mint token in asset contract", async function () {

            let transaction = await tokenMarket.connect(user1)
                .mintToken(tokenId, royalty, amount);
            await transaction.wait();

            expect(await tokenStorage.isTokenMinted(tokenAsset.address, tokenId)).to.equal(true);
            let mintedToken = await tokenStorage.getMintedToken(tokenAsset.address, tokenId);

            console.log(`Minted Token: ${mintedToken}`);
        });

        it("Should able to create sale", async function () {
            let setApproval = await tokenAsset.connect(user1).setApprovalForAll(tokenMarket.address, true);
            await setApproval.wait();

            await expect(tokenMarket.connect(user1)
                .createSale(tokenAsset.address, tokenId, tokenPrice, amount)
            ).to.emit(tokenMarket, 'TokenListed');
        });

        it("Should able to buy token", async function () {

            let itemId = await tokenStorage.getTokenListingCount(tokenAsset.address, tokenId)

            await expect(tokenMarket.connect(user2)
                .buyToken(tokenAsset.address, tokenId, itemId, {value: parsedPrice})
            ).to.emit(tokenMarket, 'TokenBought');

            expect(await tokenAsset.balanceOf(user2.address, tokenId)).to.equal(amount);
        });
    });
});
