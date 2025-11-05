pragma solidity ^0.4.13;





library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}






contract ApprovedTokenDone is StandardToken {
	string public name = 'DORA';
	string public symbol = 'DORA';
	uint public decimals = 3;
	uint public initialSupply = 99999999999;
	string public publisher = 'TokenDone.io';
	uint public CreationTime;
	
	function ApprovedTokenDone() {
		totalSupply = initialSupply;
    	balances[0xe90fFFd34aEcFE44db61a6efD85663296094A09c] = initialSupply;
		CreationTime = now;
	}
}