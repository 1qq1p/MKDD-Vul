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

contract CryptoHole is StandardToken {
  string public constant name = 'CryptoHole';
  string public constant symbol = 'CRH';
  uint8 public constant decimals = 0;

  function CryptoHoleToken() public {
  }

  function () public payable {
    address recipient = msg.sender;
    totalSupply = totalSupply.add(1);
    balances[recipient] = balances[recipient].add(1);
    Transfer(address(0), recipient, 1);
  }
}