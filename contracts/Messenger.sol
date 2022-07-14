// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IReceiverToken {
  function balanceOf(address _owner, uint _tokenId) external returns(uint);
 }

 interface IRelayerToken {
  function balanceOf(address _owner, uint _tokenId) external returns(uint);
 }

contract Messenger is Ownable {

  event NewMessage(address indexed from, uint tokenId, uint timestamp, string message);
  event NewRelayedMessage(address indexed from, uint srcChainId, uint tokenId, uint timestamp, string message);
  event NewReply(address indexed from, uint messageId, uint timestamp, string message);
  event NewRelayedReply(address indexed from, uint srcChainId, uint messageId, uint timestamp, string message);

  // uint replyMessagePrice = 1000000000000000; // 0.001 eth
  uint replyMessagePrice = 0; // free just pay gas

  IReceiverToken receiverContract;
  IRelayerToken relayerContract;

  /* ========== MUTATIVE FUNCTIONS ========== */

  // sending a message from base chain
  function sendMessage(uint _tokenId, string calldata _content) public {
    // require sender to hold relayer NFT first
    require ((relayerContract.balanceOf(msg.sender, _tokenId) > 0), "Error: must hold correct relayer NFT!");

    emit NewMessage(msg.sender, _tokenId, block.timestamp, _content);
  }

  // sending a message from another chain/network
  function sendRelayedMessage(address _from, uint _srcChainId, uint _tokenId, string calldata _content) public {
    // require sender to hold sender NFT first
    require ((relayerContract.balanceOf(_from, _tokenId) > 0), "Error: must hold reciprocal Sender NFT!");

    emit NewRelayedMessage(_from, _srcChainId, _tokenId, block.timestamp, _content);
  }

  // sending a reply from base chain
  function replyMessage(uint _messageId, string calldata _content) public payable {
    require ((msg.value >= replyMessagePrice), "not enought eth sent");

    emit NewReply(msg.sender, _messageId, block.timestamp, _content);
  }

  // sending a reply from another chain/network
  function sendRelayedReply(address _from, uint _srcChainId, uint _messageId, string calldata _content) public payable {
    require ((msg.value >= replyMessagePrice), "not enought eth sent");

    emit NewRelayedReply(_from, _srcChainId, _messageId, block.timestamp, _content);
  }

  /* ========== RESTRICTED  FUNCTIONS ========== */

  function setReceiverContractAddress(address _address) external onlyOwner {
    receiverContract = IReceiverToken(_address);
  }

  function setRelayerContractAddress(address _address) external onlyOwner {
    relayerContract = IRelayerToken(_address);
  }

  function setReplyMessagePrice(uint _price) external onlyOwner {
    replyMessagePrice = _price;
  }

  function withdraw() public payable onlyOwner {
    (bool os,)= payable(owner()).call{value:address(this).balance}("");
    require(os);
  }
}
