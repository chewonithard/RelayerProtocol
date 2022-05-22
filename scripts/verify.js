const main = async () => {
  await hre.run("verify:verify", {
    // address: "0x809b4e374255192C4987F4f2CFFAfc2304Fa1b2b", // input deployed contract address here
    // constructorArguments: ["Keywords", "KW", ""],
    address: "0xE3C6aAc0b23CE5D5794Fe01FEb1304A3eC938B37",
  });
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
