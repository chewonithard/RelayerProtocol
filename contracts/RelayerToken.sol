// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title Relayer
 * @author Relayer Team
 *
 * ERC1155 contract for Relayer NFT Minter.
*/

interface IReceiverToken {
  function initialMintReceiver(address to, uint tokenId, uint amount, string memory _keyword) external;
 }

interface IExternalContract {
  function owner() external view returns (address);
}

contract RelayerToken is ERC1155, Ownable {
  /* ========== STATE VARIABLES ========== */
  // NFT name
  string public name;

  // NFT symbol
  string public symbol;

  /* ========== INTERFACES ========== */
  IReceiverToken receiverContract;
  IExternalContract externalContract;

  /* ========== MODIFIERS ========== */


  /* ========== EVENTS ========== */
  event RelayerInitialMint(address indexed to, uint tokenId, uint amount, string keyword, address _contract, uint timestamp);
  event RelayerMint(address indexed to, uint tokenId, uint amount, uint timestamp);
  event RelayerBurn(address indexed from,  uint tokenId, uint amount, uint timestamp);
  event UpdateTokenOwner(uint indexed tokenId, address newOwner);
  event UpdateTokenProfilePic(uint indexed tokenId, string profilePic);
  event UpdateTokenLink(uint indexed tokenId, string officialLink);
  event RelayerTransfer(address indexed from, address to, uint id, uint amount, uint timestamp);
  event RelayerBatchTransfer(address indexed from, address to, uint256[] ids, uint256[] amounts, uint timestamp);

  /* ========== STRUCTS ========== */
  struct Token {
    uint _supply;
    string _keyword;
    address _contract;
    address _verifiedOwner;
    string _profilePic;
    string _officialLink;
  }

  /* ========== EXTERNAL MAPPINGS ========== */

  // Mapping from token ID to token existence
  mapping(uint => bool) public exists;

   // Mapping from token ID to token URI
  mapping (uint => string) public getUri;

  // Mapping of token Id to Token struct
  mapping (uint => Token) public tokens;

  /* ========== CONSTANTS ========== */

  string senderSvgSmall = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: black; font-family: monospace; font-size: 24px; }</style><rect width='100%' height='100%' fill='none' /><rect width='40%' height='12%' x='30%' y='43.5%' fill='none' stroke='black' stroke-width='0.5%' rx='20px' ry='20px' stroke-linejoin='round' /><text x='56%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  string senderSvgBig = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: black; font-family: monospace; font-size: 22px; }</style><rect width='100%' height='100%' fill='gold' /><rect width='80%' height='12%' x='10%' y='43.5%' fill='none' stroke='black' stroke-width='0.5%' rx='20px' ry='20px' stroke-linejoin='round' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  /* ========== CONSTRUCTOR ========== */
  constructor(string memory _name, string memory _symbol, string memory _uri) ERC1155(_uri) {name = _name; symbol = _symbol;}

  /* ========== MUTATIVE FUNCTIONS ========== */

  function initialMint(address _contract, string memory _keyword, uint _amount) external {
    // interface with external contract for verification
    externalContract = IExternalContract(_contract);

    // hash keyword into unique token Id
    uint _tokenId = _getTokenId((_keyword));

    // require keyword not to exist, i.e. it is initial mint
    require (!exists[_tokenId]);

    // checks that external contract owner is msg.sender
    require(externalContract.owner() == msg.sender);

    // require keyword to be of correct length
    require((bytes(_keyword).length > 0) && (bytes(_keyword).length < 21), "keyword length must be > 0 and < 21");

    // decide small or big svg based on length of keyword
    string memory senderSvg;

    if(bytes(_keyword).length < 11) {
     senderSvg = senderSvgSmall;
    } else {
     senderSvg = senderSvgBig;
    }

    // mint for relayer token and trigger minting of receiver tokens, set URI
    string memory tokenUri = _encodeUri(_keyword, senderSvg);
    _mint(msg.sender, _tokenId, _amount, new bytes(0));
    _setTokenURI(_tokenId, tokenUri);

    // mint receiver token with identical token id and keyword
    receiverContract.initialMintReceiver(msg.sender, _tokenId, _amount, _keyword);

    // administrative stuff
    exists[_tokenId] = true;
    tokens[_tokenId] = Token(_amount, _keyword, _contract, msg.sender, "", "");

    emit RelayerInitialMint(msg.sender, _tokenId, _amount, _keyword, _contract, block.timestamp);
  }

  function mintRelayer(uint _tokenId, uint _amount) external {
    // only verified owner can mint more tokens
    require(tokens[_tokenId]._verifiedOwner == msg.sender);

    _mint(msg.sender, _tokenId, _amount, new bytes(0));
    tokens[_tokenId]._supply = tokens[_tokenId]._supply + _amount;

    emit RelayerMint(msg.sender, _tokenId, _amount, block.timestamp);
  }

  function burn(address _from, uint _tokenId, uint _amount) external {
    require((msg.sender == _from || tokens[_tokenId]._verifiedOwner == msg.sender || msg.sender == owner()), "must be owner of token or verified owner (aka deployer address), or is contract owner");

    _burn(_from, _tokenId, _amount);
    tokens[_tokenId]._supply = tokens[_tokenId]._supply - _amount;

    // remove keyword from existence if supply goes to zero
    if (tokens[_tokenId]._supply <= 0) {
      exists[_tokenId] = false;
    }

    emit RelayerBurn(_from, _tokenId, _amount, block.timestamp);
  }

  function updateTokenOwner(uint _tokenId, address _newOwner) external {
    require (tokens[_tokenId]._verifiedOwner == msg.sender || msg.sender == owner(), "must be verified owner of token or contract owner");

    tokens[_tokenId]._verifiedOwner = _newOwner;

    emit UpdateTokenOwner(_tokenId, _newOwner);
  }

  function updateTokenProfilePic(uint _tokenId, string memory _profilePic) external {
    require (tokens[_tokenId]._verifiedOwner == msg.sender || msg.sender == owner(), "must be verified owner of token or contract owner");

    tokens[_tokenId]._profilePic = _profilePic;

    emit UpdateTokenProfilePic(_tokenId, _profilePic);
  }

  function updateTokenLink(uint _tokenId, string memory _officialLink) external {
    require (tokens[_tokenId]._verifiedOwner == msg.sender || msg.sender == owner(), "must be verified owner of token or contract owner");

    tokens[_tokenId]._officialLink = _officialLink;

    emit UpdateTokenLink(_tokenId, _officialLink);
  }

  /* ========== VIEW FUNCTIONS ========== */

  /* ========== INTERNAL FUNCTIONS ========== */

  function _setTokenURI(uint tokenId, string memory newuri) internal {
      getUri[tokenId] = newuri;
  }

  function _encodeUri(string memory _keyword, string memory _svg) internal pure returns (string memory) {
    string memory finalSvg = string(abi.encodePacked(_svg, _keyword, "</text></svg>"));
    string memory backgroundColor;

    backgroundColor = "Gold";

    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    // We set the title of our NFT as the generated word along with the role in brackets
                    '{"keyword": "',
                    _keyword,
                    '", "description": "Relayer tokens for projects, DAOs and communities", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg
                    Base64.encode(bytes(finalSvg)),
                    '", "attributes": [{"trait_type":"Role", "value":"Sender"}, {"trait_type":"Background", "value":"', backgroundColor,'"}]}'
                )
            )
        )
    );

    string memory finalTokenUri = string(
      abi.encodePacked("data:application/json;base64,", json)
    );

    return finalTokenUri;
  }

  function _getTokenId(string memory _keyword) internal pure returns (uint) {
    uint hashDigits = 8;
    uint hashModulus = 10 ** hashDigits;

    uint tokenId = uint(keccak256(abi.encodePacked(_keyword)));

    return tokenId % hashModulus;
  }

  /* ========== RESTRICTED  FUNCTIONS ========== */

  // owner mint function to faciliate airdrops to other projects
  function ownerInitialMint(address _contract, string memory _keyword, uint _amount) external onlyOwner {
    // hash keyword into unique token Id
    uint _tokenId = _getTokenId((_keyword));

    externalContract = IExternalContract(_contract);

    // decide small or big svg based on length of keyword
    string memory senderSvg;

    if(bytes(_keyword).length < 11) {
     senderSvg = senderSvgSmall;
    } else {
     senderSvg = senderSvgBig;
    }

    // mint for relayer token and trigger minting of receiver tokens, set URI
    string memory tokenUri = _encodeUri(_keyword, senderSvg);
    _mint(msg.sender, _tokenId, _amount, new bytes(0));
    _setTokenURI(_tokenId, tokenUri);

    // mint receiver token with identical token id and keyword
    receiverContract.initialMintReceiver(msg.sender, _tokenId, _amount, _keyword);

    // administrative stuff
    exists[_tokenId] = true;
    tokens[_tokenId] = Token(_amount, _keyword, _contract, msg.sender, "", "");

    emit RelayerInitialMint(msg.sender, _tokenId, _amount, _keyword, _contract, block.timestamp);
  }

  function ownerMint(uint _tokenId, uint _amount) external onlyOwner {
    _mint(msg.sender, _tokenId, _amount, new bytes(0));
    tokens[_tokenId]._supply = tokens[_tokenId]._supply + _amount;

    emit RelayerMint(msg.sender, _tokenId, _amount, block.timestamp);
  }

  // set address of receiver contract
  function setReceiverContractAddress(address _address) external onlyOwner {
    receiverContract = IReceiverToken(_address);
  }

  // soulbound nft implementation with only owner allowed to transfer to faciliate initial airdrop of nfts
  function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) public override onlyOwner{
    _safeTransferFrom(from, to, id, amount, data);

    emit RelayerTransfer(from, to, id, amount, block.timestamp);
  }

   // soulbound nft implementation with only owner allowed to transfer to faciliate initial airdrop of nfts
  function safeBatchTransferFrom(address from, address to, uint[] memory ids, uint[] memory amounts, bytes memory data) public override onlyOwner {
    _safeBatchTransferFrom(from, to, ids, amounts, data);

    emit RelayerBatchTransfer(from, to, ids, amounts, block.timestamp);
  }
}
