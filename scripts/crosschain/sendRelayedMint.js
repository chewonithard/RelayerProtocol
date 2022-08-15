const main = async () => {
  const contractFactory = await hre.ethers.getContractFactory("RelayReceiverMint");
  const contract = await contractFactory.attach(
    // "0x809b4e374255192C4987F4f2CFFAfc2304Fa1b2b" // ftm
    "0xbbB02313B7F3efB25D221AF9976ebE36EE923Fb3" // fuji
  );

  const dstChainId = 10010
  const dstAddr = "0x7cAC75A9cEab281f50532C6a5451516C6B937AB5" // arbi testnet contract
  // const refundAddr = "0xDdcDA6F7592D23c56b4058F65E6e98f02cD6D2a7";

  let tx = await (
    await contract.relayReceiverMint(
      dstChainId,
      dstAddr,
      16014359, // tokenId
      2, // amount
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
