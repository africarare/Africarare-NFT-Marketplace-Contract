import { expect } from "chai";
import { BigNumber, Signer } from "ethers";
import { ethers } from "hardhat";
import { before } from "mocha";
import {logger} from "../config/winston.config";

import {
  AfricarareNFT,
  AfricarareNFT__factory,
  AfricarareNFTFactory__factory,
  AfricarareNFTFactory,
  AfricarareNFTMarketplace__factory,
  AfricarareNFTMarketplace,
  Token__factory,
  IERC20,
} from "../typechain";

function toWei(value: number) {
  return ethers.utils.parseEther(value.toString());
}

describe("Africarare Marketplace", () => {
  let nft: AfricarareNFT;
  let factory: AfricarareNFTFactory;
  let marketplace: AfricarareNFTMarketplace;
  let owner: Signer;
  let creator: Signer;
  let buyer: Signer;
  let offerer: Signer;
  let bidder: Signer;
  let payableToken: IERC20;
  const creatorRoyaltyPercentage = 999; //9.99%
  const platformFee = 999; // 9.99%
  const testPurchaserWalletBalance = 10; // 10 ETH
  const offerPrice = 1.1; //1ETH
  const listPrice = 1; //1ETH
  const initialBidPrice = 1.05; //1.05ETH
  const winningBidPrice = 1.1; //1.1ETH
  const minimumBidPrice = 0.01; //0.01ETH, how much extra you must bid i.e 0.01ETH higher than last time

  // rinkeby
  // let proxyRegistryAddress = "0x1E525EEAF261cA41b809884CBDE9DD9E1619573A";
    // mainnet
    // let proxyRegistryAddress = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
  logger.info("Test suite started")
  logger.info("Platform fee is 9.99% in integer is: " + platformFee)
  logger.info("Creator royalty percentage is 9.99% in integer is: " + creatorRoyaltyPercentage)
  logger.info("Offer price for testing is 1 ETH, in wei is: " + toWei(offerPrice))
  logger.info("Test list price is 1 ETH, in wei is: " + toWei(listPrice))
  logger.info("Test first bid price is 1.05 ETH, in wei is: " + toWei(initialBidPrice))
  logger.info("Test winning bid price is 1.05 ETH, in wei is: " + toWei(winningBidPrice))
  logger.info("Test min bid price is 0.05 ETH, in wei is: " + toWei(minimumBidPrice))
  logger.info("Test min bid price is 0.05 ETH, in wei is: " + toWei(minimumBidPrice))

  before(async () => {
    [owner, creator, buyer, offerer, bidder] = await ethers.getSigners();
    const Factory = new AfricarareNFTFactory__factory(owner);
    factory = await Factory.deploy();
    await factory.deployed();
    expect(factory.address).not.eq(null, "Deploying factory failed.");

    const Marketplace = new AfricarareNFTMarketplace__factory(owner);

    const feeRecipient = await owner.getAddress();
    marketplace = await Marketplace.deploy(
      platformFee,
      feeRecipient,
      factory.address
    );
    await marketplace.deployed();
    expect(marketplace.address).not.eq(null, "Deploying marketplace failed");

    const Token = new Token__factory(owner);
    payableToken = await Token.deploy("Africarare Token", "UBU");
    await payableToken.deployed();
    expect(payableToken.address).not.eq(
      null,
      "Deploy test payable token has failed."
    );

    await marketplace.connect(owner).addPayableToken(payableToken.address);
    expect(
      await marketplace.checkIsPayableToken(payableToken.address),
      "Add payable token has failed."
    ).to.true;

    // Transfer payable token to testers
    const buyerAddress = await buyer.getAddress();
    const offererAddress = await offerer.getAddress();
    const bidderAddress = await bidder.getAddress();
    await payableToken.connect(owner).transfer(buyerAddress, toWei(testPurchaserWalletBalance));
    expect(await payableToken.balanceOf(buyerAddress)).to.eq(toWei(testPurchaserWalletBalance));
    await payableToken.connect(owner).transfer(offererAddress, toWei(testPurchaserWalletBalance));
    expect(await payableToken.balanceOf(offererAddress)).to.eq(toWei(testPurchaserWalletBalance));
    await payableToken.connect(owner).transfer(bidderAddress, toWei(testPurchaserWalletBalance));
    expect(await payableToken.balanceOf(bidderAddress)).to.eq(toWei(testPurchaserWalletBalance));

    const royaltyRecipient = await creator.getAddress();
    const tx = await factory
      .connect(creator)
      .createNFTCollection(
        "Africarare Collection",
        "AFRICARARE",
        creatorRoyaltyPercentage,
        royaltyRecipient
      );
    const receipt = await tx.wait();
    const events = receipt.events?.filter(
      (e: any) => e.event == "CreatedNFTCollection"
    ) as any;
    const collectionAddress = events[0].args.nft;
    nft = new ethers.Contract(
      collectionAddress,
      AfricarareNFT__factory.abi,
      creator
    ) as AfricarareNFT;
    expect(nft.address).not.eq(null, "Create collection has failed.");
  });

  describe("List and Buy", () => {
    const tokenId = 0;
    it("Creator should mint NFT", async () => {
      const to = await creator.getAddress();
      const uri = "africarare.io";
      await nft.connect(creator).safeMint(to, uri);
      expect(await nft.ownerOf(tokenId)).to.eq(to, "Mint NFT has failed.");
    });

    it("Creator should list NFT on the marketplace", async () => {
      await nft.connect(creator).approve(marketplace.address, tokenId);

      const tx = await marketplace
        .connect(creator)
        .listNft(nft.address, tokenId, payableToken.address, toWei(listPrice));
      const receipt = await tx.wait();
      const events = receipt.events?.filter(
        (e: any) => e.event == "ListedNFT"
      ) as any;
      const eventNFT = events[0].args.nft;
      const eventTokenId = events[0].args.tokenId;
      expect(eventNFT).eq(nft.address, "NFT is incorrect.");
      expect(eventTokenId).eq(tokenId, "TokenId is incorrect.");
    });

    it("Creator should cancel listed item", async () => {
      await marketplace.connect(creator).cancelListedNFT(nft.address, tokenId);
      expect(await nft.ownerOf(tokenId)).eq(
        await creator.getAddress(),
        "Cancel listed item has failed."
      );
    });

    it("Creator should list NFT on the marketplace again!", async () => {
      await nft.connect(creator).approve(marketplace.address, tokenId);

      const tx = await marketplace
        .connect(creator)
        .listNft(nft.address, tokenId, payableToken.address, toWei(listPrice));
      const receipt = await tx.wait();
      const events = receipt.events?.filter(
        (e: any) => e.event == "ListedNFT"
      ) as any;
      const eventNFT = events[0].args.nft;
      const eventTokenId = events[0].args.tokenId;
      expect(eventNFT).eq(nft.address, "NFT address is incorrect.");
      expect(eventTokenId).eq(tokenId, "TokenId is incorrect.");
    });

    it("Buyer should buy listed NFT", async () => {
      const tokenId = 0;
      // const buyPrice = 100001;
      await payableToken
        .connect(buyer)
        .approve(marketplace.address, toWei(listPrice));
      await marketplace
        .connect(buyer)
        .buyNFT(nft.address, tokenId, payableToken.address, toWei(listPrice));
      expect(await nft.ownerOf(tokenId)).eq(
        await buyer.getAddress(),
        "Buy NFT has failed."
      );
    });
  });

  describe("List, Offer, and Accept Offer", () => {
    const tokenId = 1;
    it("Creator should mint NFT", async () => {
      const to = await creator.getAddress();
      const uri = "africarare.io";
      await nft.connect(creator).safeMint(to, uri);
      expect(await nft.ownerOf(tokenId)).to.eq(to, "Mint NFT has failed.");
    });

    it("Creator should list NFT on the marketplace", async () => {
      await nft.connect(creator).approve(marketplace.address, tokenId);

      const tx = await marketplace
        .connect(creator)
        .listNft(nft.address, tokenId, payableToken.address, toWei(listPrice));
      const receipt = await tx.wait();
      const events = receipt.events?.filter(
        (e: any) => e.event == "ListedNFT"
      ) as any;
      const eventNFT = events[0].args.nft;
      const eventTokenId = events[0].args.tokenId;
      expect(eventNFT).eq(nft.address, "NFT is incorrect.");
      expect(eventTokenId).eq(tokenId, "TokenId is incorrect.");
    });

    it("Buyer should offer an amount of ether for an NFT", async () => {
      await payableToken
        .connect(buyer)
        .approve(marketplace.address, toWei(offerPrice));
      const tx = await marketplace
        .connect(buyer)
        .offerNFT(
          nft.address,
          tokenId,
          payableToken.address,
          toWei(offerPrice)
        );
      const receipt = await tx.wait();
      const events = receipt.events?.filter(
        (e: any) => e.event == "OfferedNFT"
      ) as any;
      const eventOfferer = events[0].args.offerer;
      const eventNFT = events[0].args.nft;
      const eventTokenId = events[0].args.tokenId;
      expect(eventOfferer).eq(
        await buyer.getAddress(),
        "Offerer address is incorrect."
      );
      expect(eventNFT).eq(nft.address, "NFT address is incorrect.");
      expect(eventTokenId).eq(tokenId, "TokenId is incorrect.");
    });

    it("Buyer should cancel offer", async () => {
      const tx = await marketplace
        .connect(buyer)
        .cancelOfferNFT(nft.address, tokenId);
      const receipt = await tx.wait();
      const events = receipt.events?.filter(
        (e: any) => e.event == "CanceledOfferedNFT"
      ) as any;
      const eventNFT = events[0].args.nft;
      const eventTokenId = events[0].args.tokenId;
      const eventOfferer = events[0].args.offerer;
      expect(eventOfferer).eq(
        await buyer.getAddress(),
        "Offerer address is incorrect."
      );
      expect(eventNFT).eq(nft.address, "NFT address is incorrect.");
      expect(eventTokenId).eq(tokenId, "TokenId is incorrect.");
    });

    it("Offerer should offer NFT", async () => {
      await payableToken
        .connect(offerer)
        .approve(marketplace.address, toWei(offerPrice));
      const tx = await marketplace
        .connect(offerer)
        .offerNFT(
          nft.address,
          tokenId,
          payableToken.address,
          toWei(offerPrice)
        );
      const receipt = await tx.wait();
      const events = receipt.events?.filter(
        (e: any) => e.event == "OfferedNFT"
      ) as any;
      const eventOfferer = events[0].args.offerer;
      const eventNFT = events[0].args.nft;
      const eventTokenId = events[0].args.tokenId;
      expect(eventOfferer).eq(
        await offerer.getAddress(),
        "Offerer address is incorrect."
      );
      expect(eventNFT).eq(nft.address, "NFT address is incorrect.");
      expect(eventTokenId).eq(tokenId, "TokenId is incorrect.");
    });

    it("Creator should accept offer", async () => {
      await marketplace
        .connect(creator)
        .acceptOfferNFT(nft.address, tokenId, await offerer.getAddress());
      expect(await nft.ownerOf(tokenId)).eq(await offerer.getAddress());
    });
  });

  describe("Create Auction, bid place, and Result auction", async () => {
    const tokenId = 2;
    it("Creator should mint NFT", async () => {
      const to = await creator.getAddress();
      const uri = "africarare.io";
      await nft.connect(creator).safeMint(to, uri);
      expect(await nft.ownerOf(tokenId)).to.eq(to, "Mint NFT has failed.");
    });

    it("Creator should create auction", async () => {
      // const price = 10000;
      // const minBid = 500;
      const startTime = Date.now() + 60 * 60 * 24; // a day
      const endTime = Date.now() + 60 * 60 * 24 * 7; // 7 days
      await nft.connect(creator).approve(marketplace.address, tokenId);
      const tx = await marketplace
        .connect(creator)
        .createAuction(
          nft.address,
          tokenId,
          payableToken.address,
          toWei(listPrice),
          toWei(minimumBidPrice),
          BigNumber.from(startTime),
          BigNumber.from(endTime)
        );
      const receipt = await tx.wait();
      const events = receipt.events?.filter(
        (e: any) => e.event == "CreatedAuction"
      ) as any;
      const eventNFT = events[0].args.nft;
      const eventTokenId = events[0].args.tokenId;
      const eventCreator = events[0].args.creator;
      expect(eventNFT).eq(nft.address, "NFT address is incorrect.");
      expect(eventCreator).eq(
        await creator.getAddress(),
        "Creator address is incorrect."
      );
      expect(eventTokenId).eq(tokenId, "TokenId is incorrect.");
    });

    it("Creator should cancel auction", async () => {
      await marketplace.connect(creator).cancelAuction(nft.address, tokenId);
      expect(await nft.ownerOf(tokenId)).eq(
        await creator.getAddress(),
        "Cancel has failed."
      );
    });

    it("Creator should create auction again", async () => {
      // const price = 10000;
      // const minBid = 500;
      const startTime = 0; // now
      const endTime = Date.now() + 60 * 60 * 24 * 7; // 7 days
      await nft.connect(creator).approve(marketplace.address, tokenId);
      const tx = await marketplace
        .connect(creator)
        .createAuction(
          nft.address,
          tokenId,
          payableToken.address,
          toWei(listPrice),
          toWei(minimumBidPrice),
          BigNumber.from(startTime),
          BigNumber.from(endTime)
        );
      const receipt = await tx.wait();
      const events = receipt.events?.filter(
        (e: any) => e.event == "CreatedAuction"
      ) as any;
      const eventNFT = events[0].args.nft;
      const eventTokenId = events[0].args.tokenId;
      const eventCreator = events[0].args.creator;
      expect(eventNFT).eq(nft.address, "NFT address is incorrect.");
      expect(eventCreator).eq(
        await creator.getAddress(),
        "Creator address is incorrect."
      );
      expect(eventTokenId).eq(tokenId, "TokenId is incorrect.");
    });

    it("Bidder 1 should bid place", async () => {
      // const initialBidPrice = 10500;
      await payableToken
        .connect(buyer)
        .approve(marketplace.address, toWei(initialBidPrice));
      const tx = await marketplace
        .connect(buyer)
        .bidPlace(nft.address, tokenId, toWei(initialBidPrice));
      const receipt = await tx.wait();
      const events = receipt.events?.filter(
        (e: any) => e.event == "PlacedBid"
      ) as any;
      const eventNFT = events[0].args.nft;
      const eventTokenId = events[0].args.tokenId;
      const eventBidder = events[0].args.bidder;
      expect(eventNFT).eq(nft.address, "NFT address is incorrect.");
      expect(eventBidder).eq(
        await buyer.getAddress(),
        "Bidder address is incorrect."
      );
      expect(eventTokenId).eq(tokenId, "TokenId is incorrect.");
    });

    it("Bidder 2 should place new highest bid", async () => {
      // const initialBidPrice = 11000;
      await payableToken
        .connect(bidder)
        .approve(marketplace.address, toWei(winningBidPrice));
      const tx = await marketplace
        .connect(bidder)
        .bidPlace(nft.address, tokenId, toWei(winningBidPrice));
      const receipt = await tx.wait();
      const events = receipt.events?.filter(
        (e: any) => e.event == "PlacedBid"
      ) as any;
      const eventNFT = events[0].args.nft;
      const eventTokenId = events[0].args.tokenId;
      const eventBidder = events[0].args.bidder;
      expect(eventNFT).eq(nft.address, "NFT address is incorrect.");
      expect(eventBidder).eq(
        await bidder.getAddress(),
        "Bidder address is incorrect."
      );
      expect(eventTokenId).eq(tokenId, "TokenId is incorrect.");
    });

    it("Marketplace owner should call result auction with bidder 2 as winner", async () => {
      try {
        const tx = await marketplace
          .connect(owner)
          .resultAuction(nft.address, tokenId);
        const receipt = await tx.wait();
        const events = receipt.events?.filter(
          (e: any) => e.event == "ResultedAuction"
        ) as any;
        const eventNFT = events[0].args.nft;
        const eventTokenId = events[0].args.tokenId;
        const eventWinner = events[0].args.winner;
        const eventCaller = events[0].args.caller;
        expect(eventNFT).eq(nft.address, "NFT address is incorrect.");
        expect(eventTokenId).eq(tokenId, "TokenId is incorrect.");
        expect(eventWinner).eq(
          await bidder.getAddress(),
          "Winner address is incorrect."
        );
        expect(eventCaller).eq(
          await owner.getAddress(),
          "Caller address is incorrect."
        );
        expect(await nft.ownerOf(tokenId)).eq(
          eventWinner,
          "NFT owner is incorrect."
        );
      } catch (error) {}
    });
  });
});
