pragma solidity ^0.4.23;





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
    
    
    
    return a / b;
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






contract AgroTechFarmToken is PausableToken, CappedToken {

  string public constant name = "AgroTechFarm";
  string public constant symbol = "ATF";
  uint8 public constant decimals = 18;
  uint256 private constant TOKEN_CAP = 5 * 10**24;
  
  
  function AgroTechFarmToken() public CappedToken(TOKEN_CAP) {
  paused = true;
  }
  

}


