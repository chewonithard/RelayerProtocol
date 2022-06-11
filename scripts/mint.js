const main = async () => {
  const nftContractFactory = await hre.ethers.getContractFactory("SenderToken");
  const nftContract = await nftContractFactory.attach(
    "0x5d1A742B97aa701F8eb3762331065F5226De7F12" // deployed contract address
  );
   // Call the function.
  let txn = await nftContract.mintSender(1, "BAYC_");
  // Wait for it to be mined.
  await txn.wait();
  console.log("Minted NFT #1");

  // Mint another NFT for fun.
  txn = await nftContract.mintSender(1, "BAYC_");
  // Wait for it to be mined.
  await txn.wait();
 console.log("Minted NFT #2");

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
