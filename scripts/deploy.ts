import { BigNumber } from 'ethers';
import { ethers } from 'hardhat';
import { AfricarareNFTFactory__factory, AfricarareNFTMarketplace__factory } from '../typechain';


async function main() {

  const signers = await ethers.getSigners();
  const KuiNFTFactory = new AfricarareNFTFactory__factory(signers[0]);
  const africarareNFTFactory = await KuiNFTFactory.deploy();
  await africarareNFTFactory.deployed();
  console.log('AfricarareNFTFactory deployed to: ', africarareNFTFactory.address);

  const AfricarareNFTMarketplace = new AfricarareNFTMarketplace__factory(signers[0]);
  const platformFee = BigNumber.from(10); // 10%
  const feeRecipient = signers[0].address;
  const africarareNFTMarketplace =  await AfricarareNFTMarketplace.deploy(platformFee, feeRecipient, africarareNFTFactory.address);
  await africarareNFTMarketplace.deployed();
  console.log('AfricarareNFTMarketplace deployed to: ', africarareNFTMarketplace.address);
  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;

})