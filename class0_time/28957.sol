pragma solidity ^0.4.24;

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

contract CryptSureToken is StandardToken {
  string public name    = "CryptSureToken";
  string public symbol  = "CPST";
  uint8 public decimals = 18;

  
  uint256 public constant INITIAL_SUPPLY = 50000000;

  constructor() public {
    totalSupply_ = INITIAL_SUPPLY * (10 ** uint256(decimals));
    balances[msg.sender] = totalSupply_;
    transfer(msg.sender, totalSupply_);
  }  
  
  
  
  
	function transfer(address _to, uint256 _value) public returns (bool) {
		require(_to != address(this) );
		super.transfer(_to, _value);
	}  
  
  
}