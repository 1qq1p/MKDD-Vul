pragma solidity ^0.4.13;

library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    
    
    
    if (a == 0) {
      return 0;
    }

    c = a * b;
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

  


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract OMIToken is CappedToken, PausableToken {
  string public constant name = "Ecomi Token";
  string public constant symbol = "OMI";
  uint256 public decimals = 18;

  function OMIToken() public CappedToken(1000000000*1e18) {}

  
  function isOMITokenContract()
    public 
    pure 
    returns(bool)
  { 
    return true; 
  }
}