// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


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

  /* ========== EVENTS ========== */
  event RelayerInitialMint(address indexed to, uint tokenId, uint amount, string keyword, address _contract, uint timestamp);
  event RelayerMint(address indexed to, uint tokenId, uint amount, uint timestamp);
  event RelayerBurn(address indexed from,  uint tokenId, uint amount, uint timestamp);
  event RelayerTransfer(address indexed from, address to, uint id, uint amount, uint timestamp);
  event RelayerBatchTransfer(address indexed from, address to, uint256[] ids, uint256[] amounts, uint timestamp);

  /* ========== STRUCTS ========== */
  struct Token {
    uint _supply;
    string _keyword;
    address _owner;
  }

  /* ========== EXTERNAL MAPPINGS ========== */

  // Mapping from token ID to token existence
  mapping(uint => bool) public exists;

   // Mapping from token ID to token URI
  mapping (uint => string) public getUri;

  // Mapping of token Id to Token struct
  mapping (uint => Token) public tokens;

  /* ========== CONSTANTS ========== */

  string senderSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: monospace; font-size: 24px; }</style><rect width='100%' height='100%' fill='gold' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  /* ========== CONSTRUCTOR ========== */
  constructor(string memory _name, string memory _symbol, string memory _uri) ERC1155(_uri) {name = _name; symbol = _symbol;}

  /* ========== MUTATIVE FUNCTIONS ========== */

  // mint function for individuals
  function initialMint() external {

    string memory addr = Strings.toHexString(uint256(uint160(msg.sender)), 20);
    // hash address into unique token Id
    uint _tokenId = _getTokenId(addr);

    // require keyword not to exist, i.e. it is initial mint
    require (!exists[_tokenId]);

    // mint for relayer token and trigger minting of receiver tokens, set URI
    string memory tokenUri = _encodeUri(addr, senderSvg);
    _mint(msg.sender, _tokenId, 1, new bytes(0)); // amount set to 1 as individual not expected to require more
    _setTokenURI(_tokenId, tokenUri);

    // mint receiver token with identical token id and keyword
    receiverContract.initialMintReceiver(msg.sender, _tokenId, 1, addr);

    // administrative stuff
    exists[_tokenId] = true;
    tokens[_tokenId] = Token(1, addr, msg.sender);

    emit RelayerInitialMint(msg.sender, _tokenId, 1, addr, msg.sender, block.timestamp);
  }

  // post-initial mint, this function allows more relayer tokens to be minted by the owner
  function mintMoreRelayer(uint _tokenId, uint _amount) external {

    // only verified owner can mint more tokens
    require(tokens[_tokenId]._owner == msg.sender);

    _mint(msg.sender, _tokenId, _amount, new bytes(0));
    tokens[_tokenId]._supply = tokens[_tokenId]._supply + _amount;

    emit RelayerMint(msg.sender, _tokenId, _amount, block.timestamp);
  }

  function burn(address _from, uint _tokenId, uint _amount) external {
    require((msg.sender == _from || tokens[_tokenId]._owner == msg.sender || msg.sender == owner()), "must be owner"); // must be holder of token or relayer token owner, or relayer contract owner

    _burn(_from, _tokenId, _amount);
    tokens[_tokenId]._supply = tokens[_tokenId]._supply - _amount;

    // remove keyword from existence if supply goes to zero
    if (tokens[_tokenId]._supply <= 0) {
      exists[_tokenId] = false;
    }

    emit RelayerBurn(_from, _tokenId, _amount, block.timestamp);
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
                    '", "description": "Relayer-Sender tokens for projects, DAOs and communities", "image": "data:image/svg+xml;base64,',
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

  // set address of receiverToken contract
  function setReceiverContractAddress(address _address) external onlyOwner {
    receiverContract = IReceiverToken(_address);
  }

  // soulbound nft implementation
  function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) public override onlyOwner{
    _safeTransferFrom(from, to, id, amount, data);

    emit RelayerTransfer(from, to, id, amount, block.timestamp);
  }

   // soulbound nft implementation
  function safeBatchTransferFrom(address from, address to, uint[] memory ids, uint[] memory amounts, bytes memory data) public override onlyOwner {
    _safeBatchTransferFrom(from, to, ids, amounts, data);

    emit RelayerBatchTransfer(from, to, ids, amounts, block.timestamp);
  }
}
