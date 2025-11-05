pragma solidity ^0.4.23;

contract BurnableToken is BasicToken {

	event Burn(address indexed burner, uint256 value);

    
	function burn(uint256 _value) public {
		require(_value <= balances[msg.sender]);
		
		address burner = msg.sender;
		balances[burner] = balances[burner].sub(_value);
		totalSupply_ = totalSupply_.sub(_value);
		emit Burn(burner, _value);
		
		emit Transfer(burner, address(0), _value);
	}
}


