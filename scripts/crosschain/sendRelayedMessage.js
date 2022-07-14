const main = async () => {
  const contractFactory = await hre.ethers.getContractFactory("RelayMessenger");
  const contract = await contractFactory.attach(
    // "0x85665f47280c0bD90940a9643297c5290C2ae266" // rinkeby
    "0x12d9b09aC11b2fD785244F505B3cE18C6C47e99D" // ftm
  );

  const dstChainId = 10001
  const dstAddr = "0x22CE55CE35d8BD708E66eF992F6d5B682497C13f";

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
