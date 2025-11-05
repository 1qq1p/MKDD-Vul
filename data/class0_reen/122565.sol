pragma solidity ^0.4.25;





library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); 
    uint256 c = a / b;
    

    return c;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  



  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}







contract Freezable is Ownable{
  mapping (address => bool) public frozenAccount;
    
  event FrozenFunds(address target, bool frozen);
    
  modifier whenUnfrozen(address target) {
    require(!frozenAccount[target]);
    _;
  }
  
  function freezeAccount(address target, bool freeze) onlyOwner public{
    frozenAccount[target] = freeze;
    emit FrozenFunds(target, freeze);
  }
}
