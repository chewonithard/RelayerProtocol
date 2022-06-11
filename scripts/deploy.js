const hre = require("hardhat");

const main = async () => {
  // const nftContractFactory = await hre.ethers.getContractFactory("ReceiverToken");
  // const nftContract = await nftContractFactory.deploy("QWERTY", "Receiver", "");

  // const nftContractFactory = await hre.ethers.getContractFactory("SenderToken");
  // const nftContract = await nftContractFactory.deploy("QWERTY", "Sender", "");

  const nftContractFactory = await hre.ethers.getContractFactory("Messenger");
  const nftContract = await nftContractFactory.deploy();

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
