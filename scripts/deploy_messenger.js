const hre = require("hardhat");

const main = async () => {
  const ContractFactory = await hre.ethers.getContractFactory("Messenger");
  const Contract = await ContractFactory.deploy();

  await Contract.deployed();
  console.log("Contract deployed to:", Contract.address);

  await Contract.setRelayerContractAddress(
    "0x6D81652Ff9D3a39a99ba3db1D094D2233D31979e"
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
