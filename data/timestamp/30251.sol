pragma solidity ^0.4.25;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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

contract AbstractCon {
    function allowance(address _owner, address _spender)  public pure returns (uint256 remaining);
    function transferFrom(address _from, address _to, uint256 _value) public  returns (bool success);
    function token_rate() public returns (uint256);
    function minimum_token_sell() public returns (uint16);
    function decimals() public returns (uint8);
    
    
    
}

