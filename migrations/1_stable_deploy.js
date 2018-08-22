var Token = artifacts.require("./StableToken.sol");

module.exports = function(deployer) {
  deployer.deploy(Token);
};
