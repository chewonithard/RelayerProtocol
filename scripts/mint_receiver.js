const main = async () => {
    const nftContractFactory = await hre.ethers.getContractFactory(
      "ReceiverToken"
    );
    const nftContract = await nftContractFactory.attach(
      "0x26B37edC44c4d5003c5f286baAaaE67e5a91d1bB" // deployed receiver token contract address
    );


  let txn = await nftContract.mintReceiver(
    // "0xb2712cd93EF39e5696ae8ba581c3D1992e6E7f8a",
    // "BAYC",
    16014359,
    2
  );
  await txn.wait();
  console.log("Minted NFT #1");
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
