var PhysicsEngine = artifacts.require("./PhysicsEngine.sol");

module.exports = function (deployer) {
  deployer.deploy(PhysicsEngine);
};
