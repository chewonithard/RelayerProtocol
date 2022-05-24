const main = async () => {
  await hre.run("verify:verify", {
    address: "0xDde86AB72704ED1D13182BFA41Cef7b5850C1df4", // input deployed contract address here
    constructorArguments: ["Keywords", "KW", ""],
    // address: "0x0b87CB0f588C866281668e006c524734CA62f60c",
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
