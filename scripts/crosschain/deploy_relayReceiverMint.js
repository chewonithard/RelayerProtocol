const hre = require("hardhat");

const main = async () => {
  const ContractFactory = await hre.ethers.getContractFactory("RelayReceiverMint");
  const Contract = await ContractFactory.deploy(
    "0x79a63d6d8BBD5c6dfc774dA79bCcD948EAcb53FA" // rinkeby
    // "0x7dcAD72640F835B0FA36EFD3D6d3ec902C7E5acf" // ftm
  );

  await Contract.deployed();
  console.log("Contract deployed to:", Contract.address);

  await Contract.setReceiverContractAddress(
    "0x8304b1cE2bF7fB0958f641aDA015A16Bfe92e485"
  );
  console.log("Receiver Contract set!");
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
