const main = async () => {
  const nftContractFactory = await hre.ethers.getContractFactory("Messenger");
  const nftContract = await nftContractFactory.attach(
    "0x81Df0cBb990592395DAB29F17674BB339F3124C7" // deployed messenger contract address
  );

  // send message
  let txn = await nftContract.sendMessage(
    50893101,
    "Vivamus non nisl vitae tellus pulvinar tempor eget eget eros. Quisque id eros quis nulla sodales pretium ornare ac ante."
  );
  await txn.wait();
  console.log("Sent message #1!");

  // send message
  txn = await nftContract.sendMessage(
    98933866,
    "Tellus pulvinar tempor eget eget eros. Quisque id eros quis nulla sodales pretium ornare ac ante. Tellus pulvinar tempor eget eget eros. Quisque id eros quis nulla sodales pretium ornare ac ante. Tellus pulvinar tempor eget eget eros. Quisque id eros quis nulla sodales pretium ornare ac ante. Tellus pulvinar tempor eget eget eros. Quisque id eros quis nulla sodales pretium ornare ac ante."
  );
  await txn.wait();
  console.log("Sent message #2!");

  // send message
  txn = await nftContract.sendMessage(
    9931072,
    "Quisque id eros quis nulla sodales pretium ornare ac ante. Tellus pulvinar tempor eget eget eros. Quisque id eros quis nulla sodales pretium ornare ac ante. Tellus pulvinar tempor eget eget eros. Quisque id eros quis nulla sodales pretium ornare ac ante. Tellus pulvinar tempor eget eget eros. Quisque id eros quis nulla sodales pretium ornare ac ante..."
  );
  await txn.wait();
  console.log("Sent message #3!");

  // send message
  txn = await nftContract.sendMessage(
    6673307,
    "Sodales pretium ornare ac ante. Tellus pulvinar tempor eget eget eros. Quisque id eros quis nulla sodales pretium ornare ac ante. Tellus pulvinar tempor eget eget eros. Sodales pretium ornare ac ante. Sodales pretium ornare ac ante.  Quisque id eros quis nulla sodales pretium ornare ac ante. Tellus pulvinar tempor eget eget eros. Quisque id eros quis nulla sodales pretium ornare ac ante..."
  );
  await txn.wait();
  console.log("Sent message #4!");
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
