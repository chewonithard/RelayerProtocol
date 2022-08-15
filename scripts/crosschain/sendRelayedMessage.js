const main = async () => {
  const contractFactory = await hre.ethers.getContractFactory("RelayMessenger");
  const contract = await contractFactory.attach(
    // "0x85665f47280c0bD90940a9643297c5290C2ae266" // rinkeby
    // "0xe947f4d50e904D06E112FaCc668e476A7c1e96E3" // ftm
    "0xB550142023474b6730335BF294137eA8aB39e6FE" // fuji
  );

  const dstChainId = 10010;
  const dstAddr = "0x9a083ab33A0407deFa7772f8C6f43C10F6dD88A5"; // arbi testnet contract

  let tx = await (
    await contract.relayMessage(
      dstChainId,
      dstAddr,
      ethers.BigNumber.from("16014359"), // tokenId
      `Testing relay message from Fuji Testnet contract v2`, // message
      { value: ethers.utils.parseEther("0.02") }
    )
  ).wait();
  console.log(`...tx: ${tx.transactionHash}`);
};

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
