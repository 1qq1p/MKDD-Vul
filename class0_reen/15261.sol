pragma solidity ^0.4.21;







library AddressTools {
	
	


	function isContract(address a) internal view returns (bool) {
		if(a == address(0)) {
			return false;
		}
		
		uint codeSize;
		
		assembly {
			codeSize := extcodesize(a)
		}
		
		if(codeSize > 0) {
			return true;
		}
		
		return false;
	}
	
}






contract BasicToken is ERC20Basic {
	
	using SafeMath for uint256;
	
	mapping(address => uint256) public balances;
	
	uint256 public totalSupply_;
	
	
	


	function totalSupply() public view returns (uint256) {
		return totalSupply_;
	}
	
	
	




	function transfer(address _to, uint256 _value) public returns (bool) {
		require(_to != address(0));
		require(_value <= balances[msg.sender]);
		
		
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		emit Transfer(msg.sender, _to, _value);
		return true;
	}
	
	
	




	function balanceOf(address _owner) public view returns (uint256 balance) {
		return balances[_owner];
	}
	
}




