// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
pragma abicoder v2;

import "@openzeppelin/contracts/security/Pausable.sol";
import "../../lzApp/NonblockingLzApp.sol";

interface IReceiver {
  function relayedMintReceiver(address to, uint tokenId, uint amount) external;
 }

contract RelayReceiverMint is NonblockingLzApp, Pausable {
    // event to indicate new message
    event ReceiverMint(address from, uint tokenId, uint timestamp, uint amount);

    event ReceivedReceiverMint(address from, uint tokenId, uint timestamp, uint amount);

    // constructor requires the LayerZero endpoint for this chain
    constructor(address _endpoint) NonblockingLzApp(_endpoint) {}

    IReceiver receiverContract;

    function relayReceiverMint(
        uint16 _dstChainId, // see constants chainids.json
        address _dstContractAddr, // destination address of Crosschain contract
        uint _tokenId, // target token
        uint _amount // number to mint
    ) public payable {
        require(this.isTrustedRemote(_dstChainId, abi.encodePacked(_dstContractAddr)), "you must allow inbound messages to ALL contracts with setTrustedRemote()");

        emit ReceiverMint(msg.sender, _tokenId, block.timestamp, _amount);

        // encode the payload with the receiving tokenId and message content
        bytes memory payload = abi.encode(msg.sender, _tokenId, _amount);

        // use adapterParams v1 to specify more gas for the destination
        uint16 version = 1;
        uint gasForDestinationLzReceive = 350000;
        bytes memory adapterParams = abi.encodePacked(version, gasForDestinationLzReceive);

        // get the fees we need to pay to LayerZero for message delivery
        (uint messageFee, ) = lzEndpoint.estimateFees(_dstChainId, address(this), payload, false, adapterParams);
        require(msg.value >= messageFee, "msg.value < messageFee. fund this contract with more ether");

        // send LayerZero message
        lzEndpoint.send{value: messageFee}( // {value: messageFee} will be paid out of this contract!
            _dstChainId, // destination chainId
            abi.encodePacked(_dstContractAddr), // destination address of crosschain contract
            payload, // abi.encode()'ed bytes
            payable(msg.sender), // (msg.sender will be this contract) refund address (LayerZero will refund any extra gas back to caller of send()
            address(0x0), // future param, unused for this example
            adapterParams // v1 adapterParams, specify custom destination gas qty
        );
    }

    function _nonblockingLzReceive(
        uint16 /*_srcChainId8*/,
        bytes memory /*_srcAddress*/,
        uint64, /*_nonce*/
        bytes memory _payload
    ) internal override {
        // address _from;
        // assembly {
        //     _from := mload(add(_srcAddress, 20))
        // }

        // uint srcChainId = _srcChainId;

        // decode the relayed message sent thus far
        (address _from, uint _tokenId, uint _amount) = abi.decode(_payload, (address, uint, uint));

          emit ReceivedReceiverMint(_from, _tokenId, block.timestamp, _amount);

        // send relayed receiver mint
        receiverContract.relayedMintReceiver(_from, _tokenId, _amount);
    }

    function setReceiverContractAddress(address _address) external onlyOwner {
    receiverContract = IReceiver(_address);
    }

    // allow this contract to receive ether
    receive() external payable {}

    function withdraw() public payable onlyOwner {
    (bool os,)= payable(owner()).call{value:address(this).balance}("");
    require(os);
  }
}
