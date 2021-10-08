/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
      version: "0.6.6",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
  },
  networks: {
    hardhat: {
    },
    rinkeby: {
      url: "",
      accounts: ["5b5b45d846afd5e8a2209a41146074e3f6d919bee495c4f54f32146e360d937e"]
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },

};
