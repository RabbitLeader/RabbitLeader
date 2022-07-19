# RabbitLeader NFT 

## **Environment condition**
- ### hardhat
```
npm install save-dev hardhat
```
- ### dotenv
```
npm install save-dev dotenv
```
- ### openzeppelin/contracts (version 0.8.0+)
```
npm install @openzeppelin/contracts
```
- ### ERC721A
```
npm install --save-dev erc721a
```



&nbsp;

&nbsp;

# **How to deploy RabbitLeader NFT**

## **Compile RabbitLeader**
```
npx hardhat compile
```
If it has been compiled before, you can clear the cache through 'clean'
```
npx hardhat clean
```





&nbsp;

&nbsp;
## **Deploy RabbitLeader**
```
npx hardhat run scripts/deploy.js
```
and you will see the contracts address
```
The RabbitLeader Contract is at 0x5FbDB2315678afecb367f032d93F642f64180aa3
```

deploy RabbitLeader on network, example `Polygon-mumbai` network:
```
npx hardhat run scripts/deploy.js --network mumbai
```
verfly RabbitLeader Solidity code:
```
npx hardhat verify --network mumbai 0x84d0C76314812d4C683F4329801b2c45b1b6D4bE
```



&nbsp;

&nbsp;
# **How to test RabbitLeader NFT**
```
npx hardhat test
```
and you will see the following test results
```
  prepare environment
    Test RabbitLeader NFT
      tokenURI
        ✔ Should be reverts when tokenId does not exist (42ms)
      withdraw
        ✔ Should withdraw found by the owner
        ✔ Should be reverts withdraw found by the another user
        ✔ Should be reverts paused RabbitLeader Contract to stop withdraw
      paused
        ✔ Should set paused by the owner
        ✔ Should be reverts set paused by the another user
      setFreeMint
        ✔ Should setFreeMint paused by the owner
        ✔ Should be reverts setFreeMint paused by the another user
      setPublicMint
        ✔ Should setPublicMint paused by the owner
        ✔ Should be reverts setPublicMint paused by the owner
      publicMint
        ✔ Should send enough ether to mint RabbitLeader NFT (42ms)
        ✔ Should be reverts when send not enough ether to mint RabbitLeader NFT
        ✔ Should be reverts paused RabbitLeader Contract to stop publicMint
      freeMint
        ✔ Should only one freeMint can be submitted (38ms)
        ✔ Should be reverts submit multiple freeMint
        ✔ Should be reverts paused RabbitLeader Contract to stop freeMint
      mintForDev
        ✔ Should mintForDev by the owner (61ms)
        ✔ Should be reverts mintForDev by the another user
        ✔ Should be reverts paused RabbitLeader Contract to stop mintForDev
      name
        ✔ Should return RabbitLeader NFT name
      setPrice
        ✔ Should set setPrice by the owner
        ✔ Should be reverts set setPrice by the another user
      setBaseURI
        ✔ Should set setBaseURI by the owner
        ✔ Should be reverts set setBaseURI by the another user


  24 passing (3s)
```


