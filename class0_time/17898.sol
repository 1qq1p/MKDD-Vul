pragma solidity ^0.4.4;





contract XinfinUpgradeableToken is StandardToken {

  
  address public upgradeMaster;

  
  UpgradeAgent public upgradeAgent;

  
  uint256 public totalUpgraded;

  








  enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}

  


  event Upgrade(address indexed _from, address indexed _to, uint256 _value);

  


  event UpgradeAgentSet(address agent);

  


  function XinfinUpgradeableToken(address _upgradeMaster) {
    upgradeMaster = _upgradeMaster;
  }

  


  function upgrade(uint256 value) public {

      UpgradeState state = getUpgradeState();
      require(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading);

      
      require(value != 0);

      balances[msg.sender] = safeSub(balances[msg.sender], value);

      
      totalSupply = safeSub(totalSupply, value);
      totalUpgraded = safeAdd(totalUpgraded, value);

      
      upgradeAgent.upgradeFrom(msg.sender, value);
      Upgrade(msg.sender, upgradeAgent, value);
  }

  


  function setUpgradeAgent(address agent) external {


      
      require(canUpgrade());

      require(agent != 0x0);
      
      require(msg.sender == upgradeMaster);
      
      require(getUpgradeState() != UpgradeState.Upgrading);

      upgradeAgent = UpgradeAgent(agent);

      
      require(upgradeAgent.isUpgradeAgent());
      
      require(upgradeAgent.originalSupply() == totalSupply);

      UpgradeAgentSet(upgradeAgent);
  }

  


  function getUpgradeState() public constant returns(UpgradeState) {
    if(!canUpgrade()) return UpgradeState.NotAllowed;
    else if(address(upgradeAgent) == 0x00) return UpgradeState.WaitingForAgent;
    else if(totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
    else return UpgradeState.Upgrading;
  }

  




  function setUpgradeMaster(address master) public {
      require(master != 0x0);
      require(msg.sender == upgradeMaster);
      upgradeMaster = master;
  }

  


  function canUpgrade() public constant returns(bool) {
     return true;
  }

}





