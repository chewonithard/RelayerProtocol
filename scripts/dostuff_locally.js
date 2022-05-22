const hre = require("hardhat");
const { ethers } = require("ethers");

async function main() {
  const account = "0xDdcDA6F7592D23c56b4058F65E6e98f02cD6D2a7";
  const ContractFactory = await hre.ethers.getContractFactory("KeywordsNFT");
  const contract = await ContractFactory.attach("0x5FbDB2315678afecb367f032d93F642f64180aa3");

  const after = await contract.name();
  console.log("results:", after);

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
