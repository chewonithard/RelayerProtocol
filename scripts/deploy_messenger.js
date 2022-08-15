const hre = require("hardhat");

const main = async () => {
  const ContractFactory = await hre.ethers.getContractFactory("Messenger");
  const Contract = await ContractFactory.deploy();

  await Contract.deployed();
  console.log("Contract deployed to:", Contract.address);

  await Contract.setRelayerContractAddress(
    "0xb2712cd93EF39e5696ae8ba581c3D1992e6E7f8a"
  );
  console.log("RelayerContract set!");

  await Contract.setReceiverContractAddress(
    "0x26B37edC44c4d5003c5f286baAaaE67e5a91d1bB"
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
