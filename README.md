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
 Test RabbitLeader
    ✔ Should onlyOwner can set publicSale enable (855ms)
    ✔ Should publicMint success (57ms)
    ✔ Should return RabbitLeader symbol
    ✔ Should return a tokenURI (54ms)
    ✔ Should onlyOwner can withdraw contracts balances
    ✔ Should allows the owner to paused the contract
    ✔ Should not allow other owners to paused the contract


  7 passing (1s)
```


