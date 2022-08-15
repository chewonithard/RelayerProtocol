const hre = require("hardhat");

const main = async () => {
  const ContractFactory = await hre.ethers.getContractFactory("RelayReceiverMint");
  const Contract = await ContractFactory.deploy(
    // "0x79a63d6d8BBD5c6dfc774dA79bCcD948EAcb53FA" // rinkeby
    // "0x7dcAD72640F835B0FA36EFD3D6d3ec902C7E5acf" // ftm
    // "0x93f54D755A063cE7bB9e6Ac47Eccc8e33411d706" // fuji
    "0x4D747149A57923Beb89f22E6B7B97f7D8c087A00" // arbitrum-rinkeby
  );

  await Contract.deployed();
  console.log("Contract deployed to:", Contract.address);

  await Contract.setReceiverContractAddress(
    "0x26B37edC44c4d5003c5f286baAaaE67e5a91d1bB"
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
