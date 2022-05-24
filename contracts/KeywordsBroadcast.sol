// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface KeywordsNFTInterface {
  function balanceOf(address _owner, uint _tokenId) external returns(uint);
  function getRTokensOfOwner(address _owner) view external returns (uint[] memory);
  function getSTokensOfOwner(address _owner) view external returns (uint[] memory);
  function idToKeyword(uint _tokenId) view external returns (string memory);
  function mintSenderNft(string memory _keyword) external;
  function mintReceiverNft(string memory _keyword) external;

}

contract KeywordsBroadcast is Ownable {

  event NewMessage(address indexed from, uint receiverTokenId, uint timestamp, string message);

  struct Message {
    address sender;
    uint receiverTokenId;
    string content;
    uint timestamp;
  }

  Message[] messages;
  uint public messagesLength = messages.length;
  mapping (uint => Message[]) getMsgs;

  KeywordsNFTInterface keywordsNFTContract;

  function setContractAddress(address _address) external onlyOwner {
    keywordsNFTContract = KeywordsNFTInterface(_address);
  }

  function sendMessage(string calldata _content, uint receiverTokenId) public {
    // require sender to hold sender NFT first
    uint senderTokenId = receiverTokenId + 10000;
    require ((keywordsNFTContract.balanceOf(msg.sender, senderTokenId) > 0), "Error: must hold reciprocal Sender NFT!");

    getMsgs[receiverTokenId].push(Message(msg.sender, receiverTokenId, _content, block.timestamp));
    messages.push(Message(msg.sender, receiverTokenId, _content, block.timestamp));

    console.log("msg sent!");
    emit NewMessage(msg.sender, receiverTokenId, block.timestamp, _content);
  }

  function getTokenMessages(uint _tokenId) view public returns (Message[] memory) {
    return getMsgs[_tokenId];
  }

  function getMessages() view public returns (Message[] memory) {
    return messages;
  }

  function getRTokensOfOwner(address _owner) view external returns (uint[] memory) {
    return keywordsNFTContract.getRTokensOfOwner(_owner);
  }

  function getSTokensOfOwner(address _owner) view external returns (uint[] memory) {
    return keywordsNFTContract.getSTokensOfOwner(_owner);
  }

  function convertIdtoKeyword(uint _tokenId) view external returns (string memory) {
    return keywordsNFTContract.idToKeyword(_tokenId);
  }

  function mintSenderNft(string memory _keyword) external {
    return keywordsNFTContract.mintSenderNft(_keyword);
  }

   function mintReceiverNft(string memory _keyword) external {
    return keywordsNFTContract.mintSenderNft(_keyword);
  }
}
