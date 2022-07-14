const main = async () => {
  const nftContractFactory = await hre.ethers.getContractFactory("RelayReplyMessage");
  const nftContract = await nftContractFactory.attach(
    "0x44B3Bc7923680dC922F6918A2eAa0F95C9f76EDa" // rinkeby
    // "0x2b7B803a6B78054656CeDbbd05C746959fd8CF63" // ftm
  );

  // set receiver contract address
  let txn = await nftContract.setTrustedRemote(
    10012,
    "0x2b7B803a6B78054656CeDbbd05C746959fd8CF63" // ftm contract
    // 10001,
    // "0x44B3Bc7923680dC922F6918A2eAa0F95C9f76EDa" // rinkeby contract
  );
  await txn.wait();
  console.log("Set trusted remote!");
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
