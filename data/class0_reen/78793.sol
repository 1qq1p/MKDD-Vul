pragma solidity ^0.4.25;





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
		assert(b > 0); 
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





contract KToken is ERC20Token{
	string public name = "kToken";
	string public symbol = "ktoken";
	uint8 public decimals = 18;

	uint256 public totalSupplyCap = 7 * 10**8 * 10**uint256(decimals);

	constructor(address _issuer) public {
		totalSupply = totalSupplyCap;
		balances[_issuer] = totalSupplyCap;
		emit Transfer(address(0), _issuer, totalSupplyCap);
	}
}