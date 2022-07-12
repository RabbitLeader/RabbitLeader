// PDX-License-Identifier: UNLICENSED
// @author: RabbitLeader Dev

const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("Test RabbitLeader",  function() {
  let baseURL = "https://www.rabbitLeader.io/";
  // test deploy RabbitLeader and return address
  async function deoloyRabbitLeader() {
  // We define a fixture to reuse the same setup in every test. We use

    const RabbitLeader = await ethers.getContractFactory("RabbitLeader");
    const rabbitLeader = await RabbitLeader.deploy();
    const [signer, addrA, addrB] = await ethers.getSigners();
    const deploy = (await rabbitLeader.deployed()).address;
    return {deploy, signer, addrA, addrB};
  }


  it("Should publicMint success", async function() {
    // load contract
    let nft_quantity = 5;a// PDX-License-Identifier: UNLICENSED
// @author: RabbitLeader Dev

const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("Test RabbitLeader",  function() {
  let baseURL = "https://www.rabbitLeader.io/";
  let test_cid = "bafkreiedzjgkary6bm3hqi635jhg4mmfw6bzntfotb6tifouen33ez3ocq";
  // test deploy RabbitLeader and return address
  async function deoloyRabbitLeader() {
  // We define a fixture to reuse the same setup in every test. We use

    const RabbitLeader = await ethers.getContractFactory("RabbitLeader");
    const rabbitLeader = await RabbitLeader.deploy();
    const [signer, addrA, addrB] = await ethers.getSigners();
    const deploy = (await rabbitLeader.deployed()).address;
    return {deploy, signer, addrA, addrB};
  }

  it("Should onlyOwner can set publicSale enable", async function() {
    const { deploy, signer } = await loadFixture(deoloyRabbitLeader);
    const RabbitLeader = await ethers.getContractAt("RabbitLeader", deploy, signer);

    expect(await RabbitLeader.connect(signer).setPublicSale(true));

  });


  it("Should publicMint success", async function() {
    // load contract
    let nft_quantity = 5;
    const { deploy, signer } = await loadFixture(deoloyRabbitLeader);
    // load contract 
    // - getContractAt[0]  `RabbitLeader`  contract name
    // - getContractAt[1]   `deploy`       deploy address once
    // - getContractAt[2]   `signer`       onlyOwner, deployer 
    const RabbitLeader = await ethers.getContractAt("RabbitLeader", deploy, signer);
    
    // Call publicMint function
    // Setup publicSale enanble  
    await RabbitLeader.setPublicSale(true);
    await RabbitLeader.publicMint(nft_quantity);
    
    // test `owner` eq `signer`
    expect(await RabbitLeader.ownerOf(0)).eq(signer.address);
  });


  it("Should return RabbitLeader symbol", async function() {
    const { deploy, signer } = await loadFixture(deoloyRabbitLeader);
    const RabbitLeader = await ethers.getContractAt("RabbitLeader", deploy, signer);
    expect(await RabbitLeader.symbol()).to.be.equal("RL");
  });

  it("Should return a tokenUrl", async function() {
    const { deploy, signer } = await loadFixture(deoloyRabbitLeader);
    const RabbitLeader = await ethers.getContractAt("RabbitLeader", deploy, signer);
    // using extra function for test
    await RabbitLeader.setPublicSale(true);
    await RabbitLeader.publicMint(3);
    // test 
    await RabbitLeader.setTokenURL(1, test_cid);
    const tokenURL = await RabbitLeader.tokenURI(1);
    console.log(tokenURL);
    console.log(baseURL.concat(test_cid))
    expect(tokenURL).to.eq(baseURL.concat(test_cid));

  });

  it("Should onlyOwner can withdraw contracts balances", async function() {
    
  });

  it("Should allows the owner to paused the contract", async function() {
    const { deploy, signer } = await loadFixture(deoloyRabbitLeader);
    const RabbitLeader = await ethers.getContractAt("RabbitLeader", deploy, signer);
    
    expect(await RabbitLeader.connect(signer).whenPaused(true));
  })


  it("Should not allow other owners to paused the contract", async function() {
    const { deploy, signer, addrA } = await loadFixture(deoloyRabbitLeader);
    const RabbitLeader = await ethers.getContractAt("RabbitLeader", deploy, signer);
    
    // pass error
    await expect(RabbitLeader.connect(addrA).whenPaused(true)).to.be.reverted;
  })
  

});
    const { deploy, signer } = await loadFixture(deoloyRabbitLeader);
    // load contract 
    // - getContractAt[0]  `RabbitLeader`  contract name
    // - getContractAt[1]   `deploy`       deploy address once
    // - getContractAt[2]   `signer`       onlyOwner, deployer 
    const RabbitLeader = await ethers.getContractAt("RabbitLeader", deploy, signer);
    
    // Call publicMint function
    // Setup publicSale enanble  
    await RabbitLeader.setPublicSale(true);
    await RabbitLeader.publicMint(nft_quantity);
    
    // test `owner` eq `signer` 
    expect(await RabbitLeader.ownerOf(0)).eq(signer.address);
  });


  it("Should return RabbitLeader symbol", async function() {
    const { deploy, signer } = await loadFixture(deoloyRabbitLeader);
    const RabbitLeader = await ethers.getContractAt("RabbitLeader", deploy, signer);
    expect(await RabbitLeader.symbol()).to.be.equal("RL");
  });

  it("Should return a tokenUrl", async function() {
    const { deploy, signer } = await loadFixture(deoloyRabbitLeader);
    const RabbitLeader = await ethers.getContractAt("RabbitLeader", deploy, signer);
    // using extra function for test
    await RabbitLeader.setPublicSale(true);
    await RabbitLeader.publicMint(3);
    // test 
    const tokenURL = await RabbitLeader.tokenURI(1);
    expect(tokenURL).to.be.equal("https://www.rabbitleader.io/1");
  });

  it("Should onlyOwner can withdraw contracts balances", async function() {
    
  });

});
