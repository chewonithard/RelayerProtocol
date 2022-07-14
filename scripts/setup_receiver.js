const main = async () => {
  const nftContractFactory = await hre.ethers.getContractFactory("ReceiverToken");
  const nftContract = await nftContractFactory.attach(
    "0x8304b1cE2bF7fB0958f641aDA015A16Bfe92e485" // deployed receiver token contract address
  );

  // set relayer contract address
  let txn = await nftContract.setRelayerContractAddress(
    "0x6D81652Ff9D3a39a99ba3db1D094D2233D31979e"
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
