





pragma solidity ^0.4.18;





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






contract BurnableToken is StandardToken, Ownable {
 
	



	function burn(uint256 _value) public onlyOwner {
		require(_value > 0);

		address burner = msg.sender;    
										

		balances[burner] = balances[burner].sub(_value);
		totalSupply = totalSupply.sub(_value);
		Burn(burner, _value);
	}

	event Burn(address indexed burner, uint indexed value);
 
}
 