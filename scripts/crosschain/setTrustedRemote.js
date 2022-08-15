const main = async () => {
  const nftContractFactory = await hre.ethers.getContractFactory("RelayReplyMessage");
  const nftContract = await nftContractFactory.attach(
    // "0x522436c730e3c15a2FF27ea84D811fF624618Dd3" // rinkeby
    // "0x809b4e374255192C4987F4f2CFFAfc2304Fa1b2b" // ftm
    "0x9eD2D05d46685b546efFEb71B3425f3bC52CF53C" // fuji
    // "0x0F3477AF200425821208C641086ec2b819DC61f9" // arbi testnet contract
  );

  // set receiver contract address
  let txn = await nftContract.setTrustedRemote(
    // 10012,
    // "0x809b4e374255192C4987F4f2CFFAfc2304Fa1b2b" // ftm contract
    // 10001,
    // "0x522436c730e3c15a2FF27ea84D811fF624618Dd3" // rinkeby contract
    // 10006,
    // "0x9eD2D05d46685b546efFEb71B3425f3bC52CF53C" // fuji contract
    10010,
    "0x0F3477AF200425821208C641086ec2b819DC61f9" // arbi testnet contract
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
