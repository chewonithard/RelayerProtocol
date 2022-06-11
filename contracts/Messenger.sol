// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IReceiverToken {
  function balanceOf(address _owner, uint _tokenId) external returns(uint);
 }

 interface ISenderToken {
  function balanceOf(address _owner, uint _tokenId) external returns(uint);
 }

contract Messenger is Ownable {

  event NewMessage(address indexed from, uint tokenId, uint timestamp, string message);
  event NewReply(address indexed from, uint messageId, uint timestamp, string message);

  struct Message {
    address sender;
    uint tokenId;
    string content;
    uint timestamp;
  }

  uint replyMessagePrice = 1000000000000000; // 0.001 eth

  IReceiverToken receiverContract;
  ISenderToken senderContract;

  /* ========== MUTATIVE FUNCTIONS ========== */

   function sendMessage(string calldata _content, uint _tokenId) public {
    // require sender to hold sender NFT first
    require ((senderContract.balanceOf(msg.sender, _tokenId) > 0), "Error: must hold reciprocal Sender NFT!");

    emit NewMessage(msg.sender, _tokenId, block.timestamp, _content);
  }

  function replyMessage(uint _messageId, string calldata _content) public payable {
    require ((msg.value >= replyMessagePrice), "not enought eth sent");

    emit NewReply(msg.sender, _messageId, block.timestamp, _content);
  }

  /* ========== RESTRICTED  FUNCTIONS ========== */

  function setReceiverContractAddress(address _address) external onlyOwner {
    receiverContract = IReceiverToken(_address);
  }

  function setSenderContractAddress(address _address) external onlyOwner {
    senderContract = ISenderToken(_address);
  }

  function setReplyMessagePrice(uint _price) external onlyOwner {
    replyMessagePrice = _price;
  }

  function withdraw() public payable onlyOwner {
    (bool os,)= payable(owner()).call{value:address(this).balance}("");
    require(os);
  }
}
