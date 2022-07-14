const main = async () => {
  await hre.run("verify:verify", {
    address: "0x6BD5e8C7F62ab73e0b37f9B8e238a2eab21edAEC",
    constructorArguments: [
      "0x79a63d6d8BBD5c6dfc774dA79bCcD948EAcb53FA",
    ],
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
