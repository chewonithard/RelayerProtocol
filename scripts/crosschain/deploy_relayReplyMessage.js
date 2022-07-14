const hre = require("hardhat");

const main = async () => {
  const ContractFactory = await hre.ethers.getContractFactory("RelayReplyMessage");
  const Contract = await ContractFactory.deploy();

  await Contract.deployed();
  console.log("Contract deployed to:", Contract.address);

  await Contract.setMessengerContractAddress(
    "0xfba3D37e82d19a583125aa15e251a2eb1d7B84d5"
  );
  console.log("MessengerContract set!");
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
