import { run } from "hardhat";
import { MARKETPLACE_ADDRESS, NFT_FACTORY_ADDRESS, FEE_PERCENTAGE, FEE_RECIPIENT_ADDRESS } from '../cache/deploy';



async function main() {
  console.log('verifying contracts...');

  console.log("verifying nft factory contract on etherscan..");
  await run('verify:verify', {
    address: `${NFT_FACTORY_ADDRESS}`,
    contract: "contracts/factory/AfricarareNFTFactory.sol:AfricarareNFTFactory",
    constructorArguments: [],
  })
  console.log('verified');

  console.log("verifying marketplace contract on etherscan..");
  await run('verify:verify', {
    address: `${MARKETPLACE_ADDRESS}`,
    contract: "contracts/marketplace/AfricarareNFTMarketplace.sol:AfricarareNFTMarketplace",
    constructorArguments: [
      `${FEE_PERCENTAGE}`,
      `${FEE_RECIPIENT_ADDRESS}`,
      `${NFT_FACTORY_ADDRESS}`
    ],
  })
  console.log('verified');
  console.log('done verifying contracts');
}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
