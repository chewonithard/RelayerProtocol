const hre = require("hardhat");

const main = async () => {
  const nftContractFactory = await hre.ethers.getContractFactory("KeywordsNFT");
  const nftContract = await nftContractFactory.deploy("Keywords", "KW", "");

  // const nftContractFactory = await hre.ethers.getContractFactory("KeywordsBroadcast");
  // const nftContract = await nftContractFactory.deploy();

  await nftContract.deployed();
  console.log("Contract deployed to:", nftContract.address);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
