// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
pragma abicoder v2;

import "@openzeppelin/contracts/security/Pausable.sol";
import "../../lzApp/NonblockingLzApp.sol";

interface IMessenger {
  function sendRelayedReply(address _from, uint _srcChainId, uint _messageId, string calldata _content) external;
 }

contract RelayReplyMessage is NonblockingLzApp, Pausable {

  event RelayReply(address from, uint messageId, uint timestamp, string content);
  event ReceivedReply(address from, uint messageId, uint timestamp, string content);

  // constructor requires the LayerZero endpoint for this chain
  constructor(address _endpoint) NonblockingLzApp(_endpoint) {}

  IMessenger messengerContract;

  function relayReply(
      uint16 _dstChainId, // see constants chainids.json
      address _dstPingAddr, // destination address of Crosschain contract
      uint _messageId, // target message
      string memory _content // reply content
  ) public payable {
      require(this.isTrustedRemote(_dstChainId, abi.encodePacked(_dstPingAddr)), "you must allow inbound messages to ALL contracts with setTrustedRemote()");

      emit RelayReply(msg.sender, _messageId, block.timestamp, _content);

      // encode the payload with the receiving messageId and message content
      bytes memory payload = abi.encode(msg.sender, _messageId, _content);

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
          abi.encodePacked(_dstPingAddr), // destination address of Ping contract
          payload, // abi.encode()'ed bytes
          payable(msg.sender), // (msg.sender will be this contract) refund address (LayerZero will refund any extra gas back to caller of send()
          address(0x0), // future param, unused for this example
          adapterParams // v1 adapterParams, specify custom destination gas qty
      );
  }

  function _nonblockingLzReceive(
      uint16 _srcChainId,
      bytes memory /*_srcAddress*/,
      uint64, /*_nonce*/
      bytes memory _payload
  ) internal override {
      // address _from;
      // assembly {
      //     _from := mload(add(_srcAddress, 20))
      // }

      uint srcChainId = _srcChainId;

      // decode the relayed message sent thus far
      (address _from, uint _messageId, string memory _content) = abi.decode(_payload, (address, uint, string));

      // emit ReceivedMessage(_from, _messageId, block.timestamp, _content);
      emit ReceivedReply(_from, _messageId, block.timestamp, _content);

      // send relayed reply
      messengerContract.sendRelayedReply(_from, srcChainId, _messageId, _content);
  }

  function setMessengerContractAddress(address _address) external onlyOwner {
  messengerContract = IMessenger(_address);
  }

  // allow this contract to receive ether
  receive() external payable {}
}
