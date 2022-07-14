const hre = require("hardhat");

const main = async () => {
  const ContractFactory = await hre.ethers.getContractFactory("Messenger");
  const Contract = await ContractFactory.deploy();

  await Contract.deployed();
  console.log("Contract deployed to:", Contract.address);

  await Contract.setRelayerContractAddress(
    "0x5EA8e12c2d7f180bC68738674f49A3345e73E5bA"
  );
  console.log("RelayerContract set!");

  await Contract.setReceiverContractAddress(
    "0x8304b1cE2bF7fB0958f641aDA015A16Bfe92e485"
  );
  console.log("ReceiverContract set!");
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
