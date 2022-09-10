const main = async () => {
  await hre.run("verify:verify", {
    address: "0xB550142023474b6730335BF294137eA8aB39e6FE",
    constructorArguments: ["Relayer-Sender", "REL-Sender", ""],
    // address: "0x81Df0cBb990592395DAB29F17674BB339F3124C7",
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
