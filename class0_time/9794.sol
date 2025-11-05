

pragma solidity ^0.4.18;







contract NLFToken is StandardToken {
	string public name = "New Life"; 
	string public symbol = "NLF";
	uint public decimals = 18;
	uint public INITIAL_SUPPLY = 500000000 * (10 ** decimals);
	
	function NLFToken() public {
		totalSupply_ = INITIAL_SUPPLY;
		balances[msg.sender] = INITIAL_SUPPLY;
	}
}