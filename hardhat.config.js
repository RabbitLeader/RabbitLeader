require("@nomicfoundation/hardhat-toolbox");

require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.15",
  networks: {
    // polygon-mumbai
    mumbai: {
      url: process.env.POLYGON_MAINNET_RPC_URL,
      accounts: [
        process.env.PRIVATE_KEY,
      ]
    },

    rinkeby: {
      url: "",
      accounts: [
        process.env.PRIVATE_KEY,
      ]
    },

    godwoken: {
      url: process.env.GODWOKEN_MAINNER_RPC_URL,
      accounts: [
        process.env.PRIVATE_KEY,
      ]
    }    


  },
  etherscan: {
    apiKey: process.env.POLYGON_API_KEY,
  }
};

//0x5FbDB2315678afecb367f032d93F642f64180aa3
