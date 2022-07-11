// PDX-License-Identifier: UNLICENSED
// @author: RabbitLeader Dev
pragma solidity ^0.8.15;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 *
 * Y88b888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888b88Y
 * 88  8888888b.           888      888      d8b 888         888                            888                   88
 * 88  888   Y88b          888      888      Y8P 888         888                            888                   88
 * 88  888    888          888      888          888         888                            888                   88
 * 88  888   d88P  8888b.  88888b.  88888b.  888 888888      888      .d88b.   8888b.   .d88888  .d88b.  888d888  88
 * 88  8888888P"      "88b 888 "88b 888 "88b 888 888         888     d8P  Y8b     "88b d88" 888 d8P  Y8b 888P"    88
 * 88  888 T88b   .d888888 888  888 888  888 888 888         888     88888888 .d888888 888  888 88888888 888      88
 * 88  888  T88b  888  888 888 d88P 888 d88P 888 Y88b.       888     Y8b.     888  888 Y88b 888 Y8b.     888      88
 * 88  888   T88b "Y888888 88888P"  88888P"  888  "Y888      88888888 "Y8888  "Y888888  "Y88888  "Y8888  888      88
 * T88b888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888b88T
 *
 * This is the core Contract for Rabbit Leader, the difference is that other NFTs Contracts
 * The contract adopted ERC721A standard, Origin from Azuki realize
 * See https://github.com/chiru-labs/ERC721A
 * Rabbit Leader when mint token will be more gas efficient than ever nft token.
 */


contract RabbitLeader is ERC721A, Ownable, ReentrancyGuard {
    using Address for address payable;

    uint public constant maxSupply = 10000;
    uint public price = 0.02 ether;

    bool private publicSale = false;
    bool private whitelistSale = false;
    bool private paused = false;

    // Optional mapping for token URIs
    mapping (uint256 => string) private _tokenURIs;

    constructor() ERC721A("RabbitLeader", "RL") {}

    modifier lockRabbitLeader() {
        require(!paused, "The RabbitLeader Contract had locked");
        _;
    }

    function publicMint(uint quantity) external payable nonReentrant lockRabbitLeader {
        require(publicSale, "The publicSale is Failed");
        _safeMint(msg.sender, quantity);
    }

    function whitelistMint(
        uint256 quantity, 
        bytes32[] calldata _merkleProof) 
        external 
        payable 
        nonReentrant 
        lockRabbitLeader
    {
        require(whitelistSale, "The whitelistSale is Failed");
        _safeMint(msg.sender, quantity);
    }

    function setPrice(uint _price) external onlyOwner {
        price = _price;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "https://www.rabbitleader.io/"; // gas saving
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721A) returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        string memory baseURI = _baseURI();
        string memory cid = _tokenURIs[tokenId];
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, cid)) : '';
    }

    function setTokenURL(uint256 tokenId, string memory _tokenURI) external virtual {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        _tokenURIs[tokenId] = _tokenURI;
    }

    function withdraw(uint256 amount) external onlyOwner lockRabbitLeader nonReentrant {
        require(amount > 0, "The Amount is null");
        payable(_msgSender()).sendValue(amount);
    }

    function whenPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }

    function setPublicSale(bool _publicSaleStatus) external onlyOwner {
        publicSale = _publicSaleStatus;
    }

}
