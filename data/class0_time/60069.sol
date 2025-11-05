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








contract PausableToken is StandardToken, Pausable {
	function transferFrom(address from, address to, uint256 value) whenNotPaused public returns (bool) {
		return super.transferFrom(from,to,value);
	}

	function approve(address spender, uint256 value) whenNotPaused public returns (bool) {
		return super.approve(spender,value);
	}

	function transfer(address to, uint256 value) whenNotPaused public returns (bool) {
		return super.transfer(to,value);
	}

	function increaseApproval(address _spender, uint _addedValue) whenNotPaused public returns (bool) {
		return super.increaseApproval(_spender,_addedValue);
	}

	function decreaseApproval(address _spender, uint _subtractedValue) whenNotPaused public returns (bool) {
		return super.decreaseApproval(_spender,_subtractedValue);
	}
}



