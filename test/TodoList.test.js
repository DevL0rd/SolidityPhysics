const PhysicsEngine = artifacts.require('./PhysicsEngine.sol')

contract('PhysicsEngine', (accounts) => {
  before(async () => {
    this.PhysicsEngine = await PhysicsEngine.deployed()
  })
  //todo: add tests
})
