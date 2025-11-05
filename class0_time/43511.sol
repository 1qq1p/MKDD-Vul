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








contract Piezochain is DetailedERC20, StandardToken, BurnableToken, CappedToken, Pausable {
  


  function Piezochain()
    DetailedERC20('Piezochain', 'piezo', 18)
    CappedToken( 50 * (10**9) * (10**18) )
  public {

  }
  
}