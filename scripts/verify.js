const main = async () => {
  await hre.run("verify:verify", {
    address: "0xd8d46BB5859D23852278319683dd03719AAa76d5",
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
