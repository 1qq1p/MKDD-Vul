pragma solidity ^0.4.18;






















library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract UpgradeableToken is Ownable, BurnableToken, StandardToken {

    address public upgradeableTarget;       
    uint256 public totalUpgraded;           

    event Upgraded(address indexed from, address indexed to, uint256 value);

    



    
    
    function upgrade(uint256 value) external {
        require(upgradeableTarget != address(0));

        burn(value);                    
        totalUpgraded = totalUpgraded.add(value);

        UpgradeableTarget(upgradeableTarget).upgradeFrom(msg.sender, value);
        Upgraded(msg.sender, upgradeableTarget, value);
    }

    
    
    function setUpgradeableTarget(address upgradeAddress) external onlyOwner {
        upgradeableTarget = upgradeAddress;
    }

}







