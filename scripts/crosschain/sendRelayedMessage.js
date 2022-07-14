const main = async () => {
  const contractFactory = await hre.ethers.getContractFactory("RelayMessenger");
  const contract = await contractFactory.attach(
    // "0x85665f47280c0bD90940a9643297c5290C2ae266" // rinkeby
    "0xe947f4d50e904D06E112FaCc668e476A7c1e96E3" // ftm
  );

  const dstChainId = 10001
  const dstAddr = "0xD0999eCb9e09a8f6dfCBDDfD9Ad9B396B5B9F2C5";

  let tx = await (
    await contract.relayMessage(
      dstChainId,
      dstAddr,
      ethers.BigNumber.from("16014359"), // tokenId
      "Testing relay message contract v2", // message
      { value: ethers.utils.parseEther("20") }
    )
  ).wait();
  console.log(`...tx: ${tx.transactionHash}`);
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
