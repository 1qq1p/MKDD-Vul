pragma solidity ^0.4.19;





pragma solidity ^0.4.19;






pragma solidity ^0.4.19;







pragma solidity ^0.4.19;











contract UpgradeableToken is EIP20Token, Burnable {
  using SafeMath for uint;

  
  address public upgradeMaster;

  
  UpgradeAgent public upgradeAgent;

  
  uint public totalUpgraded = 0;

  








  enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}

  


  event Upgrade(address indexed from, address to, uint value);

  


  event UpgradeAgentSet(address agent);

  


  function UpgradeableToken(address master) internal {
    setUpgradeMaster(master);
  }

  


  function upgrade(uint value) public {
    UpgradeState state = getUpgradeState();
    
    require(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading);

    
    require(value != 0);

    
    upgradeAgent.upgradeFrom(msg.sender, value);
    
    
    burnTokens(msg.sender, value);
    totalUpgraded = totalUpgraded.add(value);

    Upgrade(msg.sender, upgradeAgent, value);
  }

  


  function setUpgradeAgent(address agent) onlyMaster external {
    
    require(canUpgrade());

    require(agent != 0x0);
    
    require(getUpgradeState() != UpgradeState.Upgrading);

    upgradeAgent = UpgradeAgent(agent);

    
    require(upgradeAgent.isUpgradeAgent());
    
    require(upgradeAgent.originalSupply() == totalSupply());

    UpgradeAgentSet(upgradeAgent);
  }

  


  function getUpgradeState() public view returns(UpgradeState) {
    if (!canUpgrade()) return UpgradeState.NotAllowed;
    else if (address(upgradeAgent) == 0x00) return UpgradeState.WaitingForAgent;
    else if (totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
    else return UpgradeState.Upgrading;
  }

  




  function changeUpgradeMaster(address new_master) onlyMaster public {
    setUpgradeMaster(new_master);
  }

  


  function setUpgradeMaster(address new_master) private {
    require(new_master != 0x0);
    upgradeMaster = new_master;
  }

  


  function canUpgrade() public view returns(bool) {
     return true;
  }


  modifier onlyMaster() {
    require(msg.sender == upgradeMaster);
    _;
  }
}

pragma solidity ^0.4.19;








