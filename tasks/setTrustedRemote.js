const CHAIN_ID = require("../constants/chainIds.json")
const { getDeploymentAddresses } = require("../utils/readStatic")

module.exports = async function (taskArgs, hre) {
    const dstChainId = CHAIN_ID[taskArgs.targetNetwork]
    const dstRelayerAddr = getDeploymentAddresses(taskArgs.targetNetwork)["Relayer"]
    // get local contract instance
    const relayer = await ethers.getContract("Relayer")
    console.log(`[source] relayer.address: ${relayer.address}`)

    let tx = await (await relayer.setTrustedRemote(dstChainId, dstRelayerAddr)).wait()
    console.log(`✅ [${hre.network.name}] Relayer.setTrustedRemote( ${dstChainId}, ${dstRelayerAddr} )`)
    console.log(`...tx: ${tx.transactionHash}`)
}
