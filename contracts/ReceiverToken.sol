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

contract ReceiverToken is ERC1155, Ownable {
  /* ========== STATE VARIABLES ========== */
  // Contract for KeywordsSender NFT minter
  address public SenderContract;

  // NFT name
  string public name;

  // NFT symbol
  string public symbol;

  /* ========== MODIFIERS ========== */
  modifier onlySenderContract {
      require((msg.sender == SenderContract), "caller is not SenderContract");
      _;
  }

  /* ========== EVENTS ========== */
  event ReceiverInitialMint(address indexed from, address to, uint tokenId, uint amount, uint timestamp, string keyword);
  event ReceiverMint(address indexed to, uint tokenId, uint amount, uint timestamp);
  event ReceiverBatchMint(address indexed to, uint[] tokenIds, uint[] amounts, uint timestamp);
  event ReceiverBurn(address indexed from,  uint tokenId, uint amount, uint timestamp);
  event ReceiverTransfer(address indexed from, address to, uint id, uint amount, uint timestamp);
  event ReceiverBatchTransfer(address indexed from, address to, uint256[] ids, uint256[] amounts, uint timestamp);
  event SenderContractChange(address indexed from, address to);

  /* ========== EXTERNAL MAPPINGS ========== */
  // Mapping from token ID to token supply
  mapping(uint => uint) public tokenSupply;

  // Mapping from id to token existence
  mapping(uint => bool) public _exists;

  // Mapping from token ID to token URI
  mapping (uint => string) public getUri;

  /* ========== CONSTANTS ========== */

  string receiverSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  /* ========== CONSTRUCTOR ========== */
  constructor(string memory _name, string memory _symbol, string memory _uri) ERC1155(_uri) {name = _name; symbol = _symbol;}

  /* ========== EXTERNAL FUNCTIONS ========== */

  function mintReceiver(uint tokenId, uint amount) external {
    require(_exists[tokenId], "token does not exist, mint sender token first");

    _mint(msg.sender, tokenId, amount, new bytes(0));
    emit ReceiverMint(msg.sender, tokenId, amount, block.timestamp);

    tokenSupply[tokenId] = tokenSupply[tokenId] + amount;
  }

  function mintBatchReceiver(uint[] memory ids, uint[] memory amounts) external {
    uint[] memory idExists = new uint[](ids.length);
    uint counter = 0;
    for (uint i=0; i < ids.length; i++) {
      if(_exists[ids[i]]) {
        idExists[counter]= ids[i];
        counter++;
      }
    }
    require(idExists.length == amounts.length, "Mismatched array lengths or some tokenIds do not exist");

    _mintBatch(msg.sender, idExists, amounts, new bytes(0));

    for (uint i=0; i<idExists.length; i++) {
      tokenSupply[ids[i]] = tokenSupply[ids[i]] + amounts[i];
    }

    emit ReceiverBatchMint(msg.sender, idExists, amounts, block.timestamp);
  }

  function burn(address from, uint tokenId, uint amount) external {
    require((msg.sender == from), "must be owner of token");
    require((tokenSupply[tokenId] - amount >= 1), "cannot burn last remaining token");

    _burn(from, tokenId, amount);
    tokenSupply[tokenId] - amount;

    emit ReceiverBurn(from, tokenId, amount, block.timestamp);
  }

  /* ========== VIEW FUNCTIONS ========== */
  function uri(uint256 tokenId) override public view returns (string memory){
        return(getUri[tokenId]);
  }

  /* ========== INTERNAL FUNCTIONS ========== */

  function _setTokenURI(uint256 tokenId, string memory newuri) internal {
      getUri[tokenId] = newuri;
  }

  function _encodeUri(string memory _keyword, string memory _svg) internal pure returns (string memory) {
    string memory finalSvg = string(abi.encodePacked(_svg, _keyword, "</text></svg>"));
    string memory backgroundColor;

    backgroundColor = "Black";

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
                    // Set attribute of 'role' to either sender or receiver
                    '", "attributes": [{"trait_type":"Role", "value":"Receiver"}, {"trait_type":"Background", "value":"', backgroundColor,'"}]}'
                )
            )
        )
    );

    string memory finalTokenUri = string(
      abi.encodePacked("data:application/json;base64,", json)
    );

    return finalTokenUri;
  }

  /* ========== RESTRICTED  FUNCTIONS ========== */

  // called only by sender contract when minting a fresh sender token
  function initialMintReceiver(address to, uint tokenId, uint amount, string memory _keyword) external onlySenderContract {
    require((bytes(_keyword).length > 0), "length too short");

    // Get all the JSON metadata in place and base64 encode it
    string memory tokenUri = _encodeUri(_keyword, receiverSvg);

    _mint(to, tokenId, 1, new bytes(0));
    _setTokenURI(tokenId, tokenUri);

    tokenSupply[tokenId] = tokenSupply[tokenId] + amount;
    _exists[tokenId] = true;

    emit ReceiverInitialMint(msg.sender, to, tokenId, amount, block.timestamp, _keyword);
  }

  function setSenderContractAddress(address _contract) external onlyOwner {
    address old = SenderContract;
    SenderContract = _contract;

    emit SenderContractChange(old, SenderContract);
  }

   // soulbound nft implementation with only owner allowed to transfer to faciliate initial airdrop of nfts
  function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) public override onlyOwner{
    _safeTransferFrom(from, to, id, amount, data);

    emit ReceiverTransfer(from, to, id, amount, block.timestamp);
  }

   // soulbound nft implementation with only owner allowed to transfer to faciliate initial airdrop of nfts
  function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public override onlyOwner {
    _safeBatchTransferFrom(from, to, ids, amounts, data);

    emit ReceiverBatchTransfer(from, to, ids, amounts, block.timestamp);
  }

}
