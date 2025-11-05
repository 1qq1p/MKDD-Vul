pragma solidity ^0.4.24;

library SafeMath {
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }
}

contract InsurChainCoin is BasicToken {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor() public {
    name = "InsurChain2.0";
    symbol = "INSUR";
    decimals = 18;
    totalSupply_ = 2e28;
    balances[msg.sender]=totalSupply_;
    emit Transfer(address(0), msg.sender, totalSupply_);
  }
}