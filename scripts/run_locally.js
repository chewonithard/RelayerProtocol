const main = async () => {
  const nftContractFactory = await hre.ethers.getContractFactory("KeywordsNFT");
  const nftContract = await nftContractFactory.deploy("Keywords", "KW", "");
  await nftContract.deployed();
  console.log("Contract deployed to:", nftContract.address);

  // Call the function.
  let txn = await nftContract.mintSenderNft("BAYC");
  // Wait for it to be mined.
  await txn.wait();

  // Mint another NFT for fun.
  txn = await nftContract.mintReceiverNft("BAYC");
  // Wait for it to be mined.
  await txn.wait();

  // Call the function.
  txn = await nftContract.mintSenderNft("Azuki");
  // Wait for it to be mined.
  await txn.wait();

  txn = await nftContract.balanceOf(
    "0xDdcDA6F7592D23c56b4058F65E6e98f02cD6D2a7", 10001
  );
  await txn
  console.log(txn)
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
