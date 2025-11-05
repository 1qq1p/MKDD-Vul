pragma solidity ^0.4.24;





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




contract Zillion is StandardToken {
  string public constant name = "Zillion";
  string public constant symbol = "ZION";
  uint8 public constant decimals = 6;

  function Zillion() public {
    totalSupply = 111000000000000000;
    balances[msg.sender] = totalSupply;
  }
}