import { ethers } from "hardhat";

async function deployContract() {
    const nft = await ethers.getContractFactory("OnChainNFT");

    console.log("Deploying NFT Contract...");

    const deployedContract = await nft.deploy("Olasunkanmi", "SKM");
    await deployedContract.waitForDeployment();

    console.log(`🎉 Contract deployed at: ${deployedContract.target}`);
    return deployedContract;
}

deployContract()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
});

export default deployContract;