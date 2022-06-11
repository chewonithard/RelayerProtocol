// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title Keywords
 * @author Keywords Team
 *
 * ERC1155 contract for Keywords NFTs.
*/

contract KeywordsNFT is ERC1155, Ownable {
  /* ========== STATE VARIABLES ========== */
  // Used in pausable modifier
  bool public paused;

  // NFT name
  string public name;

  // NFT symbol
  string public symbol;

  /* ========== EXTERNAL MAPPINGS ========== */
  // Mapping from token ID to token supply
  mapping(uint256 => uint256) public tokenSupply;

  // Mapping from receiver keyword to receiver token supply: for easy way to check how many ppl 'subscribe' to this keyword
  mapping(string => uint256) public rKeywordSupply;

  // Mapping from keyword to keyword existence
  mapping(string => bool) private keywordExists;

  // Mapping from token ID to keyword
  mapping(uint256 => string) public idToKeyword;

  // Mapping from keyword to token ID
  mapping(string => uint256) public keywordToId;

  // Mapping token ID to addresses holding it: to get all addresses that hold a token
  mapping (uint256 => address[]) public idToOwners;

  // Mapping from token ID to token URI
  mapping (uint256 => string) public _uris;

  /* ========== INTERNAL MAPPINGS ========== */
  // Mapping owner to number of unique receiver tokens: to be used for getRTokensOfOwner function loop by setting array length
  mapping (address => uint) internal ownerRTokenCount;

  // Mapping owner to number of unique sender tokens: to be used for getSTokensOfOwner function loop by setting array length
  mapping (address => uint) internal ownerSTokenCount;

  /* ========== CONSTANTS ========== */
  uint256 public RECEIVER_TOKEN_ID = 10001;
  uint256 public SENDER_TOKEN_ID = 20001;
  uint256 public MAX_SENDER_TOKEN_SUPPLY = 50;

  string receiverSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  string senderSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: black; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='gold' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  /* ========== CONSTRUCTOR ========== */
  constructor(string memory _name, string memory _symbol, string memory _uri) ERC1155(_uri) {name = _name; symbol = _symbol;}

  /* ========== MINT FUNCTIONS ========== */

  function mintSenderNft(string memory _keyword) external {
    require(bytes(_keyword).length > 0);
    // Get all the sender JSON metadata in place and base64 encode it
    string memory senderTokenUri = encodeUri(_keyword, senderSvg, "Sender");

    // if keyword already exists, mint allowed up to max supply
    if (keywordExists[_keyword]) {
      uint256 tokenId = keywordToId[_keyword] + 10000;
      require((tokenSupply[tokenId] < MAX_SENDER_TOKEN_SUPPLY), "max supply reached");

      // if owner did not have this sender Nft before, add his address to the idToOwners map AND increase his unique S token count
      if (balanceOf(msg.sender, tokenId) == 0) {
        idToOwners[tokenId].push(msg.sender);
        ownerSTokenCount[msg.sender]++;
      }

      _mint(msg.sender, tokenId, 1, new bytes(0));
      setTokenURI(tokenId, senderTokenUri);

      tokenSupply[tokenId]++;

    // if keyword does not exist, mint a sender AND a receiver NFT
    } else {
      uint256 tokenId = SENDER_TOKEN_ID;

      _mint(msg.sender, tokenId, 1, new bytes(0));
      setTokenURI(tokenId, senderTokenUri);

      SENDER_TOKEN_ID++;
      tokenSupply[tokenId]++;
      keywordExists[_keyword] = true;
      idToKeyword[tokenId] = _keyword;
      keywordToId[_keyword] = tokenId;
      idToOwners[tokenId].push(msg.sender);
      ownerSTokenCount[msg.sender]++;

      // mint reciprocal receiver NFT (senderTokenID 20001 reciprocal to receiverTokenId 10001)
      // Get all the receiver JSON metadata in place and base64 encode it
      string memory receiverTokenUri = encodeUri(_keyword, receiverSvg, "Receiver");

      uint256 receiverTokenId = RECEIVER_TOKEN_ID;

      _mint(msg.sender, receiverTokenId, 1, new bytes(0));
      setTokenURI(receiverTokenId, receiverTokenUri);

      RECEIVER_TOKEN_ID++;
      tokenSupply[receiverTokenId]++;
      rKeywordSupply[_keyword]++;
      idToKeyword[receiverTokenId] = _keyword;
      keywordToId[_keyword] = receiverTokenId;
      idToOwners[receiverTokenId].push(msg.sender);
      ownerRTokenCount[msg.sender]++;
    }
  }

  function mintReceiverNft(string memory _keyword) external {
    require(bytes(_keyword).length > 0);
    require ((keywordExists[_keyword]), "keyword does not exist yet, mint a sender NFT first");

    uint256 receiverTokenId = keywordToId[_keyword];

    // if owner does not own this token yet, add his address to the idToOwners map AND increase his unique token count
    if (balanceOf(msg.sender, receiverTokenId) == 0) {
      idToOwners[receiverTokenId].push(msg.sender);
      ownerRTokenCount[msg.sender]++;
    }

    _mint(msg.sender, receiverTokenId, 1, new bytes(0));
    tokenSupply[receiverTokenId]++;
    rKeywordSupply[_keyword]++;
  }

  /* ========== VIEW FUNCTIONS ========== */

  function getRTokensOfOwner(address _owner) view external returns (uint[] memory) {
    uint[] memory result = new uint[](ownerRTokenCount[_owner]);
    uint counter = 0;
    for (uint i = 10001; i < RECEIVER_TOKEN_ID; i++) {
      if (balanceOf(_owner, i) > 0) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

  function getSTokensOfOwner(address _owner) view external returns (uint[] memory) {
    uint[] memory result = new uint[](ownerSTokenCount[_owner]);
    uint counter = 0;
    for (uint i = 20001; i < SENDER_TOKEN_ID; i++) {
      if (balanceOf(_owner, i) > 0) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

  function getRKeywordsOfOwner(address _owner) view external returns (string[] memory) {
    string[] memory result = new string[](ownerRTokenCount[_owner]);
    uint counter = 0;
    for (uint i = 10001; i < RECEIVER_TOKEN_ID; i++) {
      if (balanceOf(_owner, i) > 0) {
        result[counter] = idToKeyword[i];
        counter++;
      }
    }
    return result;
  }

  function getSKeywordsOfOwner(address _owner) view external returns (string[] memory) {
    string[] memory result = new string[](ownerSTokenCount[_owner]);
    uint counter = 0;
    for (uint i = 20001; i < SENDER_TOKEN_ID; i++) {
      if (balanceOf(_owner, i) > 0) {
        result[counter] = idToKeyword[i];
        counter++;
      }
    }
    return result;
  }

  function uri(uint256 tokenId) override public view returns (string memory){
        return(_uris[tokenId]);
  }

/* ========== INTERNAL FUNCTIONS ========== */

  function setTokenURI(uint256 tokenId, string memory newuri) internal {
      _uris[tokenId] = newuri;
  }

  function encodeUri(string memory _keyword, string memory _svg, string memory _role) internal pure returns (string memory) {
    string memory finalSvg = string(abi.encodePacked(_svg, _keyword, "</text></svg>"));
    string memory backgroundColor;

    // if role is Sender, set backgroundColor to Gold, else black
    if (keccak256(abi.encodePacked(_role)) == keccak256(abi.encodePacked("Sender"))) {
      backgroundColor = "Gold";
    } else {
      backgroundColor = "Black";
    }

    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    // We set the title of our NFT as the generated word along with the role in brackets
                    '{"name": "',
                    _keyword, '(',_role,')'
                    '", "description": "A collection of keywords in Web3", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg
                    Base64.encode(bytes(finalSvg)),
                    // Set attribute of 'role' to either sender or receiver
                    '", "attributes": [{"trait_type":"Role", "value":"', _role,'"}, {"trait_type":"Background", "value":"', backgroundColor,'"}]}'
                )
            )
        )
    );

    string memory finalTokenUri = string(
      abi.encodePacked("data:application/json;base64,", json)
    );

    return finalTokenUri;
  }

}
