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



contract RabbitLeader is ERC721A, Ownable, ReentrancyGuard {
    error AlreadyMaxFreeMint();
    error AlreadyMaxPublicMintSupply();

    using Address for address payable;
    using Strings for uint256;

    uint256 public freeMintCounter;
    uint256 public publicMintCounter;

    uint256 public constant maxSupply = 1000;
    uint256 public constant maxFreeMint = 100;
    uint256 public constant maxMintForDev = 100;

    uint256 public PRICE = 0.05 ether;

    bool private isPublicSale = false;
    bool private isFreeMint = false;
    bool private paused = false;

    string private baseURI;

    mapping (address => bool) public freeMintList;
 
    constructor() ERC721A("RabbitLeader", "RL") {
        baseURI = "https://bafybeicfii3duwatup37r3mce6dczslitqygbq44euurunmnrdb5wsbb4a";
    }

    // Modifier Ensure that the caller is a real user
    modifier callerIsUers() {
        require(msg.sender == tx.origin);
        _;
    }

    // Modifier Stop of important contract functions in the event of an accident
    modifier lockRabbitLeader() {
        require(!paused, 
            "The RabbitLeader Contract had locked");
        _;
    }

    // Modifier Calculate mint cost, cost = price * quantity
    modifier mintPriceCompliance(uint256 mintQuantity) {
        require(totalSupply() + mintQuantity <= maxSupply, 
            "Mint quantity had already maxSupply");
        _;
    }

    /**
     * @dev Mint for early RabbitLeader contributors or real users
     * FreeMint before publicMint. so just check if `token` exists for each user
     * 
     * requirements:
     * - The user can only freeMint one `token`
     * - Reject any (contract, bot) to freeMint
     */
    function freeMint() external payable nonReentrant lockRabbitLeader callerIsUers {
        require(isFreeMint, 
            "The freeMint is Failed");

        require(!freeMintList[_msgSender()], 
            "The user had freeMint");

        unchecked {
            uint currentFreeMintCounter = freeMintCounter;
            if (currentFreeMintCounter > maxFreeMint) revert AlreadyMaxFreeMint();

            freeMintList[_msgSender()] = true;
            ++freeMintCounter;
        }
        // Use `mint` instead of `safeMint`, because there is no need to check.
        // see {Openzeppelin-onERC721Received}
        // `callerIsUers` make sure the recipient must be a real user
        _mint(_msgSender(), 1);
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
        require(isPublicSale, 
            "The publicSale is Failed");
        
        require(quantity != 0, 
            "The quantity was zero");

        unchecked {
            // Subtract the number of free mint parts
            uint currentPublicMintCounter = publicMintCounter;
            if (currentPublicMintCounter + quantity > maxSupply - (maxFreeMint + maxMintForDev)) revert AlreadyMaxPublicMintSupply();
            require(msg.value >= quantity * PRICE, "Need more value");
            publicMintCounter = currentPublicMintCounter + quantity;
        }
        
        _mint(_msgSender(), quantity);
    }

    function mintForDev() external onlyOwner lockRabbitLeader mintPriceCompliance(maxMintForDev) {
        uint quantity = maxMintForDev;
        _mint(_msgSender(), quantity);
    }


    //function refundIfOver(uint256 price) private {
      //  payable(_msgSender()).transfer(msg.value - PRICE);
    //}

    function setPrice(uint _price) external onlyOwner {
        PRICE = _price;
    }

    /**
     * @dev Return the baseURI for the token
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    /**
     * @dev Return the tokenURI for the `tokenid`
     * Redesigned tokenURI to be compatible with Rarible
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        string memory base_URI = _baseURI();
        return bytes(baseURI).length != 0
                ? string(
                    abi.encodePacked(
                        base_URI,
                        ".ipfs.nftstorage.link/",
                        tokenId.toString(),
                        ".json"
                        ))
                : '';
    }

    function withdraw() external onlyOwner lockRabbitLeader nonReentrant {
        uint balance = address(this).balance;
        payable(_msgSender()).sendValue(balance);
    }

    function pause(bool _paused) external onlyOwner {
        paused = _paused;
    }

    function setPublicMint(bool _PublicMint) external onlyOwner {
        isPublicSale = _PublicMint;
    }

    function setFreeMint(bool _isFreeMint) external onlyOwner {
        isFreeMint = _isFreeMint;
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        baseURI = baseURI_;
    }
}
