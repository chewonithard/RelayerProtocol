const main = async () => {
  const nftContractFactory = await hre.ethers.getContractFactory("ReceiverToken");
  const nftContract = await nftContractFactory.attach(
    "0x8304b1cE2bF7fB0958f641aDA015A16Bfe92e485" // deployed receiver token contract address
  );

  // set relayer contract address
  let txn = await nftContract.setRelayerContractAddress(
    "0x5EA8e12c2d7f180bC68738674f49A3345e73E5bA"
  );
  await txn.wait();
  console.log("Set relayer contract address!");
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
