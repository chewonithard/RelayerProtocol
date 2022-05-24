// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
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

  // Used in pausable modifier
  bool public paused;

  // NFT name
  string public name;

  // NFT symbol
  string public symbol;

  // Mapping from token ID to token supply
  mapping(uint256 => uint256) public tokenSupply;

  // Mapping from keyword to keyword existence
  mapping(string => bool) private keywordExists;

  // Mapping from token ID to keyword
  mapping(uint256 => string) public idToKeyword;

  // Mapping from keyword to token ID
  mapping(string => uint256) public keywordToId;

  // Mapping owner to number of unique receiver tokens
  mapping (address => uint) public ownerRTokenCount;

  // Mapping owner to number of unique sender tokens
  mapping (address => uint) public ownerSTokenCount;

  // Mapping from token ID to token URI
  mapping (uint256 => string) public _uris;

  uint256 public RECEIVER_TOKEN_ID = 10001;
  uint256 public SENDER_TOKEN_ID = 20001;
  uint256 public MAX_SENDER_TOKEN_SUPPLY = 50;

  string receiverSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  string senderSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: black; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='gold' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  constructor(string memory _name, string memory _symbol, string memory _uri) ERC1155(_uri) {name = _name; symbol = _symbol;}

    function mintSenderNft(string memory _keyword) external payable {

      // Get all the sender JSON metadata in place and base64 encode it
      string memory senderTokenUri = encodeUri(_keyword, senderSvg, "Sender");

      // if keyword already exists, mint allowed up to max supply
      if (keywordExists[_keyword]) {
        uint256 tokenId = keywordToId[_keyword];
        require((tokenSupply[tokenId] < MAX_SENDER_TOKEN_SUPPLY), "max supply reached");

        _mint(msg.sender, tokenId, 1, new bytes(0));
        setTokenURI(tokenId, senderTokenUri);

        tokenSupply[tokenId]++;
        ownerSTokenCount[msg.sender]++;

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
        ownerSTokenCount[msg.sender]++;

        // mint reciprocal receiver NFT (senderTokenID 20001 reciprocal to receiverTokenId 10001)
        // Get all the receiver JSON metadata in place and base64 encode it
        string memory receiverTokenUri = encodeUri(_keyword, receiverSvg, "Receiver");

        uint256 receiverTokenId = RECEIVER_TOKEN_ID;

        _mint(msg.sender, receiverTokenId, 1, new bytes(0));
        setTokenURI(receiverTokenId, receiverTokenUri);

        RECEIVER_TOKEN_ID++;
        tokenSupply[receiverTokenId]++;
        idToKeyword[receiverTokenId] = _keyword;
        keywordToId[_keyword] = receiverTokenId;
        ownerRTokenCount[msg.sender]++;
      }
    }

    function mintReceiverNft(string memory _keyword) external payable {
      require ((keywordExists[_keyword]), "keyword does not exist yet, mint a sender NFT first");

      string memory receiverTokenUri = encodeUri(_keyword, receiverSvg, "Receiver");
      uint256 receiverTokenId = keywordToId[_keyword];

      _mint(msg.sender, receiverTokenId, 1, new bytes(0));
      setTokenURI(receiverTokenId, receiverTokenUri);

      tokenSupply[receiverTokenId]++;

      // if owner does not own this token yet, increase his unique token count
      if (balanceOf(msg.sender, receiverTokenId) == 0) {
        ownerRTokenCount[msg.sender]++;
      }
    }

    function uri(uint256 tokenId) override public view returns (string memory){
        return(_uris[tokenId]);
    }

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
}
