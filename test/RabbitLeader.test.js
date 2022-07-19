const { expect } = require('chai');
const { BigNumber } = require('ethers');
const { ethers } = require("hardhat");



context('prepare environment', async () => {

    let baseuri = 'https://bafybeicfii3duwatup37r3mce6dczslitqygbq44euurunmnrdb5wsbb4a';
    let baseSuffix = '.ipfs.nftstorage.link/';
    // Deploy contracts before each test
    beforeEach(async () => {
        const RabbitLeader = await ethers.getContractFactory("RabbitLeader");
        const rabbitLeader = await RabbitLeader.deploy();
        const deploy = (await rabbitLeader.deployed()).address;
        const [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
        this.owner = owner;
        this.addr1 = addr1;
        this.addr2 = addr2;
        this.addr3 = addr3;
        this,addrs.push(addrs);

        // load RabbitLeader Contract
        this.nft = await ethers.getContractAt("RabbitLeader", deploy, owner);
    });
    
    describe('Test RabbitLeader NFT', async () => {
        describe('tokenURI', async () => {
            it('Should be reverts when tokenId does not exist', async () => {
                await expect(this.nft.tokenURI(0)).to.be.rejectedWith("URIQueryForNonexistentToken");
         });
    });


    describe('withdraw', async () => {
        it('Should withdraw found by the owner', async () => {
            await this.nft.connect(this.owner).withdraw();
        });
        
        it('Should be reverts withdraw found by the another user', async () => {
            await expect(this.nft.connect(this.addr1).withdraw()).to.be.revertedWith(
                "Ownable: caller is not the owner");
        });

        it('Should be reverts paused RabbitLeader Contract to stop withdraw', async () => {
            await this.nft.connect(this.owner).pause(true);
            await expect(this.nft.connect(this.owner).withdraw()).to.be.revertedWith(
                'The RabbitLeader Contract had locked'
            );
        });
    });


    describe('paused', async () => {
        it('Should set paused by the owner', async () => {
            await this.nft.connect(this.owner).pause(true);
        });

        it('Should be reverts set paused by the another user', async () => {
            await expect(this.nft.connect(this.addr2).pause(true)).to.be.revertedWith(
                "Ownable: caller is not the owner");;
        });
    });

    describe('setFreeMint', async () => {
        it('Should setFreeMint paused by the owner', async () => {
            await this.nft.connect(this.owner).setFreeMint(true);
        });

        it('Should be reverts setFreeMint paused by the another user', async () => {
            await expect(this.nft.connect(this.addr2).setFreeMint(true)).to.be.revertedWith(
                "Ownable: caller is not the owner");;
        });
    });

    describe('setPublicMint', async () => {
        it('Should setPublicMint paused by the owner', async () => {
            await this.nft.connect(this.owner).setPublicMint(true);
        });

        it('Should be reverts setPublicMint paused by the owner', async () => {
            await expect(this.nft.connect(this.addr2).setPublicMint(true)).to.be.revertedWith(
                "Ownable: caller is not the owner");;
        });
    });



    describe('publicMint', async ()=> {
        it('Should send enough ether to mint RabbitLeader NFT', async () => {
            // ethers type must be string 
            const send_values = {value: ethers.utils.parseEther('1')}
            await this.nft.connect(this.owner).setPublicMint(true);
            await this.nft.connect(this.addr1).publicMint(10, send_values);
            
            expect(await this.nft.ownerOf(1)).to.equal(this.addr1.address);
            expect(await this.nft.balanceOf(this.addr1.address)).to.equal(10);
            expect(await this.nft.tokenURI(1)).to.equal(baseuri + baseSuffix + 1 + '.json');
        });

        it('Should be reverts when send not enough ether to mint RabbitLeader NFT', async () => {
            // ethers type must be string 
            const send_values = {value: ethers.utils.parseEther('0.001')}
            await this.nft.connect(this.owner).setPublicMint(true);
            await expect(this.nft.connect(this.addr2).publicMint(10, send_values)).to.be.revertedWith(
                'Need more value'
            );          
        });

        it('Should be reverts paused RabbitLeader Contract to stop publicMint', async () => {
            await this.nft.connect(this.owner).pause(true);
            await this.nft.connect(this.owner).setPublicMint(true);
            await expect(this.nft.connect(this.addr1).publicMint(1)).to.be.revertedWith('The RabbitLeader Contract had locked');
        });
    });

    
    describe('freeMint', async () => {
        it('Should only one freeMint can be submitted', async () => {
            // need some ethers for gas.
            const send_values = {value: ethers.utils.parseEther('0.01')};
            await this.nft.connect(this.owner).setFreeMint(true);
            await this.nft.connect(this.addr3).freeMint();
            
            expect(await this.nft.ownerOf(1)).to.equal(this.addr3.address);
            expect(await this.nft.balanceOf(this.addr3.address)).to.equal(1);
            expect(await this.nft.tokenURI(1)).to.equal(baseuri + baseSuffix + 1 + '.json');
        });

        it('Should be reverts submit multiple freeMint', async () => {
            // need some ethers for gas.
            const send_values = {value: ethers.utils.parseEther('0.01')};
            await this.nft.connect(this.owner).setFreeMint(true);
            await this.nft.connect(this.addr3).freeMint();
            await expect(this.nft.connect(this.addr3).freeMint()).to.be.revertedWith('The user had freeMint');
        });

        it('Should be reverts paused RabbitLeader Contract to stop freeMint', async () => {
            await this.nft.connect(this.owner).pause(true);
            await this.nft.connect(this.owner).setFreeMint(true);
            await expect(this.nft.connect(this.addr2).freeMint()).to.be.revertedWith('The RabbitLeader Contract had locked');
        });
    });

    describe('mintForDev', async () => {
        // need some ethers to mint.
        it('Should mintForDev by the owner', async () => {
            const send_values = {value: ethers.utils.parseEther('1')};
            await this.nft.connect(this.owner).mintForDev();
            
            // check RabbitLeader NFT[1:100] amount
            expect(await this.nft.ownerOf(100)).to.equal(this.owner.address);
            expect(await this.nft.ownerOf(1)).to.equal(this.owner.address);
            expect(await this.nft.balanceOf(this.owner.address)).to.equal(100);
            expect(await this.nft.tokenURI(1)).to.equal(baseuri + baseSuffix + 1 + '.json');
            expect(await this.nft.tokenURI(100)).to.equal(baseuri + baseSuffix + 100 + '.json');
        });

        it('Should be reverts mintForDev by the another user', async () => {
            const send_values = {value: ethers.utils.parseEther('1')};
            await expect(this.nft.connect(this.addr2).mintForDev()).to.be.revertedWith(
                'Ownable: caller is not the owner'
            );
        });

        it('Should be reverts paused RabbitLeader Contract to stop mintForDev', async () => {
            await this.nft.connect(this.owner).pause(true);
            await expect(this.nft.connect(this.owner).mintForDev()).to.be.revertedWith(
                'The RabbitLeader Contract had locked');
        });
    });

    describe('name', async () => {
        it('Should return RabbitLeader NFT name', async () => {
            expect(await this.nft.name()).to.equal("RabbitLeader");
        });
    });


    describe('setPrice', async () => {
        it('Should set setPrice by the owner', async () => {
            // test 0.1 ether
            await this.nft.connect(this.owner).setPrice(1);
        });

        it('Should be reverts set setPrice by the another user', async () => {
            await expect(this.nft.connect(this.addr3).setPrice(1)).to.be.revertedWith(
                "Ownable: caller is not the owner");;
        });
    });

    describe('setBaseURI', async () => {
        it('Should set setBaseURI by the owner', async () => {
            // test 0.1 ether
            await this.nft.connect(this.owner).setBaseURI('https://bafybeicfii3duwatup37r3mce6dczslitqygbq44euurunmnrdb5wsbb5b');
        });

        it('Should be reverts set setBaseURI by the another user', async () => {
            await expect(this.nft.connect(this.addr3).setBaseURI('https://bafybeicfii3duwatup37r3mce6dczslitqygbq44euurunmnrdb5wsbb5b')).to.be.revertedWith(
                "Ownable: caller is not the owner");
        });
    });
});

})
