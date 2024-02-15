const { ethers, upgrades, hre } = require("hardhat");

const main = async () => {
    // Deploying Vault in an upgradeable manner
    console.log("Deploying Vault...")
    const VaultFactory = await ethers.getContractFactory("Vault");
    const vault = await VaultFactory.deploy();
    console.log('Vault deployed to:', vault.address);
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
      console.error(error);
      process.exit(1);
});