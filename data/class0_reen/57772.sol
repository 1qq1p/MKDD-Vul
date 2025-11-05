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




contract CPGToken is BurnableToken, MintableToken, PausableToken {
  
  string public name;
  string public symbol;
  
  uint8 public decimals;

  function CPGToken() public {
    name = "CastlePeak Game";
    symbol = "CPG";
    decimals = 18;
    totalSupply = 98000000 * 10 ** uint256(decimals);

    
    balances[msg.sender] = totalSupply;
  }

  
  function withdrawEther() onlyOwner public {
      owner.transfer(this.balance);
  }

  
  function() payable public {
  }
}