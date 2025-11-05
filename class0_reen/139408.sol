pragma solidity ^0.4.20;

library SafeMath {
	function add(uint a, uint b) internal pure returns (uint) {
		uint c = a + b;
		assert(c >= a);
		return c;
	}

	function sub(uint a, uint b) internal pure returns (uint) {
		assert(b <= a);
		return a - b;
	}

	function mul(uint a, uint b) internal pure returns (uint) {
		if (a == 0 || b == 0) {
			return 0;
		}
		uint c = a * b;
		assert(c / a == b);
		return c;
	}

	function div(uint a, uint b) internal pure returns (uint) {
		require(b > 0);
		uint c = a / b;
		return c;
	}
}

contract BasicToken is ERC20Basic {
	using SafeMath for uint;

	mapping(address => uint) balances;

	function transfer(address _to, uint _value) public returns (bool) {
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		Transfer(msg.sender, _to, _value);
		return true;
	}

	function balanceOf(address _owner) public view returns (uint) {
		return balances[_owner];
	}
}
