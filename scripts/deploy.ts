import * as fs from 'fs';
import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import {
  AfricarareNFTFactory__factory,
  AfricarareNFTMarketplace__factory,
} from "../typechain";

async function main() {
  const signers = await ethers.getSigners();
  const AfricarareNFTFactory = new AfricarareNFTFactory__factory(signers[0]);
  const africarareNFTFactory = await AfricarareNFTFactory.deploy();
  await africarareNFTFactory.deployed();
  console.log(
    "AfricarareNFTFactory deployed to: ",
    africarareNFTFactory.address
  );

  const AfricarareNFTMarketplace = new AfricarareNFTMarketplace__factory(
    signers[0]
  );
  const platformFee = BigNumber.from(10); // 10%

  const feeRecipient = signers[0].address;
  const africarareNFTMarketplace = await AfricarareNFTMarketplace.deploy(
    platformFee,
    feeRecipient,
    africarareNFTFactory.address
  );
  await africarareNFTMarketplace.deployed();
  console.log(
    "AfricarareNFTMarketplace deployed to: ",
    africarareNFTMarketplace.address
  );

   console.log('saving deployment details to cache/deploy.ts');
  let deployments = `
  export const MARKETPLACE_ADDRESS = "${africarareNFTMarketplace.address}"
  export const NFT_FACTORY_ADDRESS = "${africarareNFTFactory.address}"
  export const FEE_RECIPIENT_ADDRESS = "${feeRecipient}"
  export const FEE_PERCENTAGE = "${platformFee}"
  `

  let data = JSON.stringify(deployments)
  fs.writeFileSync('cache/deploy.ts', JSON.parse(data))
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
