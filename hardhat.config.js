require("@nomiclabs/hardhat-waffle");
require("dotenv").config({ path: ".env" });
require("@nomiclabs/hardhat-etherscan");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.1",
  networks: {
    // cronostest: {
    //   url: "https://evm-t3.cronos.org/" || "",
    //   accounts:
    //     process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    // },
    // fuji: {
    //   url: process.env.FUJI_URL || "",
    //   accounts:
    //     process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    // },
    mumbai: {
      url: process.env.MUMBAI_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    // fantomtest: {
    //   url: process.env.FANTOM_TESTNET_URL || "",
    //   accounts:
    //     process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    // },
    rinkeby: {
      url: process.env.RINKEBY_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    ropsten: {
      url: process.env.ROPSTEN_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    kiln: {
      url: process.env.KILN_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
  },
  etherscan: {
    apiKey: {
      polygonMumbai: process.env.MUMBAI_API_KEY,
      // avalancheFujiTestnet: process.env.FUJI_API_KEY,
      // ftmTestnet: "",
      ropsten: process.env.ROPSTEN_API_KEY,
      rinkeby: process.env.RINKEBY_API_KEY,
      // cronostest: process.env.CRONOSTEST_API_KEY
    },
  },
};
