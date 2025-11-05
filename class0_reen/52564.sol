pragma solidity 0.4.15;

contract GECToken is StandardToken {

	
	string public name = "GECoin";
    string public symbol = "GEC";
    uint public decimals = 3;

	
	function GECToken (address _bank, uint _totalSupply) {
		balances[_bank] += _totalSupply;
		totalSupply += _totalSupply;
	}

	
	
	function transfer(address _recipient, uint _amount)
		returns (bool o_success)
	{
		return super.transfer(_recipient, _amount);
	}

	
	
	function transferFrom(address _from, address _recipient, uint _amount)
		returns (bool o_success)
	{
		return super.transferFrom(_from, _recipient, _amount);
	}
}