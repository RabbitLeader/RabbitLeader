// PDX-License-Identifier: UNLICENSED
// @author: RabbitLeader Dev
pragma solidity ^0.8.15;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

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


error AlreadyMaxFreeMint();
error AlreadyMaxSupply();
error AlreadyMaxPublicMintSupply();

contract RabbitLeader is ERC721A, Ownable, ReentrancyGuard {
    using Address for address payable;
    using Strings for string;

    uint256 public freeMintCounter;
    uint256 public publicMintCounter;

    uint256 public constant maxSupply = 10000;
    uint256 public constant maxFreeMint = 500;
    uint256 public price = 0.02 ether;

    bool private isPublicSale = false;
    bool private isFreeMint = false;
    bool private paused = false;


    // Optional mapping for token URIs
    mapping (uint256 => bytes) private _tokenURIs;
    
    

    constructor() ERC721A("RabbitLeader", "RL") {}

    // Modifier Ensure that the caller is a real user
    modifier callerIsUers() {
        require(msg.sender == tx.origin);
        _;
    }

    // Modifier Stop of important contract functions in the event of an accident
    modifier lockRabbitLeader() {
        require(!paused, "The RabbitLeader Contract had locked");
        _;
    }

    // Modifier Calculate mint cost, cost = price * quantity
    modifier mintPriceCompliance(uint256 mintQuantity) {
        require(msg.value >= price * mintQuantity);
        _;
    }

    /**
     * @dev Mint for early RabbitLeader contributors or real users
     * FreeMint before publicMint. so just check if `token` exists for each user
     * 
     * requirements:
     * - The user can only freeMint one `token`
     * - Reject any contract to freeMint
     */
    function freeMint(
        uint256 quantity
    )
        external payable
        nonReentrant
        lockRabbitLeader
        callerIsUers {
        require(isFreeMint, "The freeMint is Failed");
        require(quantity > 0 && quantity <= maxFreeMint);

        uint currentFreeMintCounter = freeMintCounter;
        if (currentFreeMintCounter <= maxFreeMint) revert AlreadyMaxFreeMint();
        if (totalSupply() + quantity <= maxSupply) revert AlreadyMaxSupply();
        require(balanceOf(msg.sender) == 0, "The User have freeMint");
        
        _mint(msg.sender, quantity);
        ++freeMintCounter;
    }
    
    /**
     * @dev When the owner setup `isPublicSale`, publicMint start working
     */
    function publicMint(
        uint quantity
    )
        external payable
        callerIsUers
        nonReentrant
        lockRabbitLeader
        mintPriceCompliance(quantity) {
        require(isPublicSale, "The publicSale is Failed");
        // Subtract the number of free mint parts
        uint currentPublicMintCounter = publicMintCounter;
        if (currentPublicMintCounter <= maxSupply - maxFreeMint) revert AlreadyMaxPublicMintSupply();

        if (totalSupply() + quantity <= maxSupply) revert AlreadyMaxSupply();

        // Use `mint` instead of `safeMint`, because there is no need to check.
        // see {Openzeppelin-onERC721Received}
        // `callerIsUers` make sure the recipient must be a real user
        _mint(msg.sender, quantity);
        // gas saving
        ++publicMintCounter;
    }

    function setPrice(uint _price) external onlyOwner {
        price = _price;
    }

    /**
     * @dev Return The baseURI for the token
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return "https://ipfs/"; // gas saving
    }

    /**
     * @dev Return the tokenURI for the `tokenid`
     * Redesigned tokenURI to be compatible with Rarible
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 
                ? string(
                    abi.encodePacked(
                        baseURI,
                        _tokenURIs[tokenId],
                        ".json"))
                            : '';
    }

    function setTokenURI(uint256 tokenId, bytes calldata cid) external virtual {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        _tokenURIs[tokenId] = cid;
    }

    function withdraw() external onlyOwner lockRabbitLeader nonReentrant {
        uint balance = address(this).balance;
        payable(_msgSender()).sendValue(balance);
    }

    function pause(bool _paused) external onlyOwner {
        paused = _paused;
    }

    function setPublicSale(bool _publicSaleStatus) external onlyOwner {
        isPublicSale = _publicSaleStatus;
    }

    function setIsFreeMint(bool _isFreeMint) external onlyOwner {
        isFreeMint = _isFreeMint;
    }
}
