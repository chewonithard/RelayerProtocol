const main = async () => {
  const contractFactory = await hre.ethers.getContractFactory("RelayReplyMessage");
  const contract = await contractFactory.attach(
    "0x2b7B803a6B78054656CeDbbd05C746959fd8CF63" // ftm
  );

  const dstChainId = 10001
  const dstAddr = "0x44B3Bc7923680dC922F6918A2eAa0F95C9f76EDa";

  let tx = await (
    await contract.relayReply(
      dstChainId,
      dstAddr,
      "160143-messageId-test-2222", // messageId
      "Testing relay reply contract v2", // message
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
