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

interface IReceiverToken {
  function initialMintReceiver(address to, uint tokenId, uint amount, string memory _keyword) external;
 }

interface IExternalContract {
  function owner() external view returns (address);
}

contract SenderToken is ERC1155, Ownable {
  /* ========== STATE VARIABLES ========== */
  // NFT name
  string public name;

  // NFT symbol
  string public symbol;

  // Mint price
  uint public mintPrice = 100000000000000000; // 0.1 ETH

  // Used in pausable modifier
  bool public paused;

  /* ========== INTERFACES ========== */
  IReceiverToken receiverContract;
  IExternalContract externalContract;

  /* ========== MODIFIERS ========== */
  modifier pausable {
        require(!paused, "Paused");
        _;
    }

  /* ========== EVENTS ========== */
  event SenderInitialMint(address indexed to, uint tokenId, uint amount, uint timestamp, string keyword);
  event SenderInitialVerifiedMint(address indexed to, address contract_addr, uint tokenId, uint amount, uint timestamp, string keyword);
  event SenderMint(address indexed to, uint tokenId, uint amount, uint timestamp);
  event SenderBurn(address indexed from,  uint tokenId, uint amount, uint timestamp);
  event SenderTransfer(address indexed from, address to, uint id, uint amount, uint timestamp);
  event SenderBatchTransfer(address indexed from, address to, uint256[] ids, uint256[] amounts, uint timestamp);
  event SenderContractChange(address indexed from, address to);

  /* ========== EXTERNAL MAPPINGS ========== */
  // Mapping from token ID to token supply
  mapping(uint256 => uint) public tokenSupply;

  // Mapping from token ID to token existence
  mapping(uint => bool) public _exists;

   // Mapping from token ID to token URI
  mapping (uint => string) public getUri;

  // Mapping from token ID to verified owner address
  mapping (uint => address) public idToVerifiedOwner;

  /* ========== CONSTANTS ========== */

  string senderSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  /* ========== CONSTRUCTOR ========== */
  constructor(string memory _name, string memory _symbol, string memory _uri) ERC1155(_uri) {name = _name; symbol = _symbol;}

  /* ========== MUTATIVE FUNCTIONS ========== */

  function mintSender(string memory _keyword, uint _amount) payable external pausable {
    require((msg.value >= mintPrice), "not enough eth sent");

    _myMint(_keyword, _amount);
  }

  function mintVerifiedSender(address _contract, string memory _keyword, uint _amount) external {
    // interface with external contract
    externalContract = IExternalContract(_contract);
    // hashes keyword into unique token Id
    uint tokenId = _getTokenId((_keyword));

    // checks that external contract owner is msg.sender
    require(externalContract.owner() == msg.sender);
    require((bytes(_keyword).length > 0), "length too short");

    // if token does not exist, initial mint for both sender and receiver tokens, set URI
    if (!_exists[tokenId]) {
      string memory tokenUri = _encodeUri(_keyword, senderSvg);

      _mint(msg.sender, tokenId, _amount, new bytes(0));
      _setTokenURI(tokenId, tokenUri);

      // mint receiver token with identical token id and keyword
      receiverContract.initialMintReceiver(msg.sender, tokenId, _amount, _keyword);

      tokenSupply[tokenId] = tokenSupply[tokenId] + _amount;
      _exists[tokenId] = true;
      idToVerifiedOwner[tokenId] = msg.sender;

      emit SenderInitialVerifiedMint(msg.sender, _contract, tokenId, _amount, block.timestamp, _keyword);
      return;
    }

    // if token already exists, only the contract owner can mint more sender tokens
    require(idToVerifiedOwner[tokenId] == msg.sender);

    _mint(msg.sender, tokenId, _amount, new bytes(0));
    tokenSupply[tokenId] = tokenSupply[tokenId] + _amount;

    emit SenderMint(msg.sender, tokenId, _amount, block.timestamp);
  }

  function burn(address _from, uint _tokenId, uint _amount) external {
    require((msg.sender == _from), "must be owner of token");
    require((tokenSupply[_tokenId] - _amount >= 1), "cannot burn last remaining token");

    _burn(_from, _tokenId, _amount);
    tokenSupply[_tokenId] = tokenSupply[_tokenId] - _amount;

    emit SenderBurn(_from, _tokenId, _amount, block.timestamp);
  }

  /* ========== VIEW FUNCTIONS ========== */
  function uri(uint _tokenId) override public view returns (string memory){
        return(getUri[_tokenId]);
  }

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
                    '{"name": "',
                    _keyword,
                    '", "description": "A collection of keywords in Web3", "image": "data:image/svg+xml;base64,',
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

  function _myMint(string memory _keyword, uint _amount) internal {
    require((bytes(_keyword).length > 0), "length too short");

    uint tokenId = _getTokenId((_keyword));

    // if token exists, mint normally
    if (_exists[tokenId]) {
      _mint(msg.sender, tokenId, _amount, new bytes(0));
      tokenSupply[tokenId] = tokenSupply[tokenId] + _amount;

      emit SenderMint(msg.sender, tokenId, _amount, block.timestamp);
      return;
    }
    // if token does not exist, initial mint for both sender and receiver tokens, set URI
    string memory tokenUri = _encodeUri(_keyword, senderSvg);

    _mint(msg.sender, tokenId, _amount, new bytes(0));
    _setTokenURI(tokenId, tokenUri);

    // mint receiver token with identical token id and keyword
    receiverContract.initialMintReceiver(msg.sender, tokenId, _amount, _keyword);

    tokenSupply[tokenId] = tokenSupply[tokenId] + _amount;
    _exists[tokenId] = true;

    emit SenderInitialMint(msg.sender, tokenId, _amount, block.timestamp, _keyword);
  }

  /* ========== RESTRICTED  FUNCTIONS ========== */

  // owner mint function to faciliate airdrops to other projects
  function ownerMint(string memory _keyword, uint _amount) external onlyOwner {
    _myMint(_keyword, _amount);
  }

  // set address of receiver contract
  function setReceiverContractAddress(address _address) external onlyOwner {
    receiverContract = IReceiverToken(_address);
  }

  // Pause or unpause the contract
  function pause() external onlyOwner {
        paused = !paused;
    }

  // soulbound nft implementation with only owner allowed to transfer to faciliate initial airdrop of nfts
  function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) public override onlyOwner{
    _safeTransferFrom(from, to, id, amount, data);

    emit SenderTransfer(from, to, id, amount, block.timestamp);
  }

   // soulbound nft implementation with only owner allowed to transfer to faciliate initial airdrop of nfts
  function safeBatchTransferFrom(address from, address to, uint[] memory ids, uint[] memory amounts, bytes memory data) public override onlyOwner {
    _safeBatchTransferFrom(from, to, ids, amounts, data);

    emit SenderBatchTransfer(from, to, ids, amounts, block.timestamp);
  }

}
