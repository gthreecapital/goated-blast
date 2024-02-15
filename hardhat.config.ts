import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import dotenv from "dotenv";

dotenv.config();

module.exports = {
  solidity: {
    version: '0.8.20',
    settings: {
      optimizer: {
        enabled: true
      },
    }
  },
  networks: {
    "blast-sepolia": {
      url: "https://rpc.ankr.com/blast_testnet_sepolia",
      accounts: [process.env.PRIVATE_KEY as string],
      gasPrice: 1000000000,
    }},
  defaultNetwork: "blast-sepolia",
};
