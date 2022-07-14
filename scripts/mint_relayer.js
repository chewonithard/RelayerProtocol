const main = async () => {
  const nftContractFactory = await hre.ethers.getContractFactory("RelayerToken");
  const nftContract = await nftContractFactory.attach(
    "0x6D81652Ff9D3a39a99ba3db1D094D2233D31979e" // deployed contract address
  );

  // set receiver contract address
  let txn = await nftContract.setReceiverContractAddress(
    "0x8304b1cE2bF7fB0958f641aDA015A16Bfe92e485"
  );
  await txn.wait();
  console.log("Set receiver contract address!");

  txn = await nftContract.initialMint(
    "0x7B745018E7BfFb41fC1766E3E6EFd4143f033609",
    "BAYC",
    2
  );
  await txn.wait();
  console.log("Minted NFT #1");

  txn = await nftContract.initialMint(
    "0x7B745018E7BfFb41fC1766E3E6EFd4143f033609",
    "Azuki",
    3
  );
  await txn.wait();
  console.log("Minted NFT #2");

  txn = await nftContract.initialMint(
    "0xfba3D37e82d19a583125aa15e251a2eb1d7B84d5",
    "Murakami Flowers",
    2
  );
  await txn.wait();
  console.log("Minted NFT #3");

  txn = await nftContract.initialMint(
    "0xEeE268463142D3FA07c0fBEa6792E428F7382616",
    "CryptoPunks",
    1
  );
  await txn.wait();
  console.log("Minted NFT #4");

  txn = await nftContract.initialMint(
    "0x8D86be9A31a14E27AaF7997aA86Ca6A0855Ad015",
    "Gh0stlyGh0sts",
    3
  );
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
