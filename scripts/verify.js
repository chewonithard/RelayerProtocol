const main = async () => {
  await hre.run("verify:verify", {
    // address: "0x5EA8e12c2d7f180bC68738674f49A3345e73E5bA",
    // constructorArguments: ["Relayer", "REL", ""],
    address: "0x51be187A2164eF85cd03e5EB242C3E05D51941EB",
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
