const hre = require("hardhat");

const main = async () => {
  const ContractFactory = await hre.ethers.getContractFactory("RelayMessenger");
  const Contract = await ContractFactory.deploy(
    // "0x79a63d6d8BBD5c6dfc774dA79bCcD948EAcb53FA" // rinkeby
    "0x7dcAD72640F835B0FA36EFD3D6d3ec902C7E5acf" // ftm
  );

  await Contract.deployed();
  console.log("Contract deployed to:", Contract.address);

  // await Contract.setMessengerContractAddress(
  //   "0xfba3D37e82d19a583125aa15e251a2eb1d7B84d5"
  // );
  // console.log("MessengerContract set!");
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
