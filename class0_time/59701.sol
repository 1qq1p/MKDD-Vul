pragma solidity ^0.4.15;

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

  function toUINT112(uint256 a) internal pure returns(uint112) {
    assert(uint112(a) == a);
    return uint112(a);
  }

  function toUINT120(uint256 a) internal pure returns(uint120) {
    assert(uint120(a) == a);
    return uint120(a);
  }

  function toUINT128(uint256 a) internal pure returns(uint128) {
    assert(uint128(a) == a);
    return uint128(a);
  }
}

contract AEFTOKEN is StandardToken {

  string public constant name = "AISI ECO FOF";
  string public constant symbol = "aef";
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 180000000 * (10 ** uint256(decimals));

  


  function AEFTOKEN() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}