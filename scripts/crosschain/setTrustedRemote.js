const main = async () => {
  const nftContractFactory = await hre.ethers.getContractFactory("RelayMessenger");
  const nftContract = await nftContractFactory.attach(
    // "0xD0999eCb9e09a8f6dfCBDDfD9Ad9B396B5B9F2C5" // rinkeby
    "0xe947f4d50e904D06E112FaCc668e476A7c1e96E3" // ftm
  );

  // set receiver contract address
  let txn = await nftContract.setTrustedRemote(
    // 10012,
    // "0xe947f4d50e904D06E112FaCc668e476A7c1e96E3" // ftm contract
    10001,
    "0xD0999eCb9e09a8f6dfCBDDfD9Ad9B396B5B9F2C5" // rinkeby contract
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
