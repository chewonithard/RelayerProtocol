const main = async () => {
  await hre.run("verify:verify", {
    // address: "0xB66F66522b6Bb03fc307b4faDea91E049d94a434",
    // constructorArguments: ["QWERTY", "Receiver", ""],
    address: "0x3c3B0Fe25ADA3a0e6f62a38Bc479BC1201446B50",
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
