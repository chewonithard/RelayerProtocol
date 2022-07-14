const CHAIN_ID = require("../constants/chainIds.json")
const { getDeploymentAddresses } = require("../utils/readStatic")

module.exports = async function (taskArgs, hre) {
    const dstChainId = CHAIN_ID[taskArgs.targetNetwork]
    const dstRelayerAddr = getDeploymentAddresses(taskArgs.targetNetwork)["Relayer"]
    // get local contract instance
    const relayer = await ethers.getContract("Relayer")
    console.log(`[source] relayer.address: ${relayer.address}`)

    let tx = await (
        await relayer.relayMessage(
            dstChainId,
            dstRelayerAddr,
            16014359, // tokenId
            "Test message from Rinkeby",
            { value: ethers.utils.parseEther("5") }
        )
    ).wait()
    console.log(`✅ Pings started! [${hre.network.name}] pinging with target chain [${dstChainId}] @ [${dstRelayerAddr}]`)
    console.log(`...tx: ${tx.transactionHash}`)
}
