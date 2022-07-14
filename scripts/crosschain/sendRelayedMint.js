const main = async () => {
  const contractFactory = await hre.ethers.getContractFactory("RelayReceiverMint");
  const contract = await contractFactory.attach(
    // "0x85665f47280c0bD90940a9643297c5290C2ae266" // rinkeby
    "0xABeF53281d0432100173Fd4A3f42A34A7906Cd30" // ftm
  );

  const dstChainId = 10001
  const dstAddr = "0x85665f47280c0bd90940a9643297c5290c2ae266";

  let tx = await (
    await contract.relayReceiverMint(
      dstChainId,
      dstAddr,
      16014359, // tokenId
      2, // amount
      { value: ethers.utils.parseEther("15") }
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
