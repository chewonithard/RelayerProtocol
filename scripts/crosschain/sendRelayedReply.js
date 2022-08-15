const main = async () => {
  const contractFactory = await hre.ethers.getContractFactory("RelayReplyMessage");
  const contract = await contractFactory.attach(
    // "0x2b7B803a6B78054656CeDbbd05C746959fd8CF63" // ftm
    "0x9eD2D05d46685b546efFEb71B3425f3bC52CF53C" // fuji
  );

  const dstChainId = 10010
  const dstAddr = "0x0F3477AF200425821208C641086ec2b819DC61f9";

  let tx = await (
    await contract.relayReply(
      dstChainId,
      dstAddr,
      "0xddcda6f7592d23c56b4058f65e6e98f02cd6d2a7-16014359-1657951436", // messageId
      "[Reply from Fuji Testnet] Tellus pulvinar tempor eget eget eros. Quisque id eros quis nulla sodales pretium ornare ac ante. Tellus pulvinar tempor eget eget eros.", // message
      { value: ethers.utils.parseEther("0.02") }
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
