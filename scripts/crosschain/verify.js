const main = async () => {
  await hre.run("verify:verify", {
    address: "0x9eD2D05d46685b546efFEb71B3425f3bC52CF53C",
    constructorArguments: ["0x93f54D755A063cE7bB9e6Ac47Eccc8e33411d706"],
    // address: "0xfba3D37e82d19a583125aa15e251a2eb1d7B84d5",
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
