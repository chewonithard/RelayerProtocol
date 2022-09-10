const { ethers } = require("hardhat");

const main = async () => {
  const nftContractFactory = await hre.ethers.getContractFactory("RelayerToken");
  const nftContract = await nftContractFactory.attach(
    "0xB550142023474b6730335BF294137eA8aB39e6FE" // deployed contract address
  );
  const [owner, addr1, addr2, addr3, addr4] = await ethers.getSigners();

  // set receiver contract address
  let txn = await nftContract.setReceiverContractAddress(
    "0x26B37edC44c4d5003c5f286baAaaE67e5a91d1bB"
  );
  await txn.wait();
  console.log("Set receiver contract address!");

  // let txn = await nftContract.mintRelayer(
  //   // "0xb2712cd93EF39e5696ae8ba581c3D1992e6E7f8a",
  //   // "BAYC",
  //   6673307,
  //   3
  // );
  // await txn.wait();
  // console.log("Minted NFT #1");

  // let txn = await nftContract.safeTransferFrom(
  //   "0xDdcDA6F7592D23c56b4058F65E6e98f02cD6D2a7",
  //   "0x38B6C2d5aCd36BBD879a08EFCf8F351994f35A34",
  //   9931072,
  //   1,
  //   0x0
  // );
  // await txn.wait();
  // console.log("Minted NFT #1");
  txn = await nftContract.initialMint();
  await txn.wait();
  console.log("Minted NFT #1");

  txn = await nftContract.connect(addr1).initialMint();
  await txn.wait();
  console.log("Minted NFT #2");

  txn = await nftContract.connect(addr2).initialMint();
  await txn.wait();
  console.log("Minted NFT #3");

  txn = await nftContract.connect(addr3).initialMint();
  await txn.wait();
  console.log("Minted NFT #4");

  txn = await nftContract.connect(addr4).initialMint();
  await txn.wait();
  console.log("Minted NFT #5");

}

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
