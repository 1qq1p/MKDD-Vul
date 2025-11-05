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

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
