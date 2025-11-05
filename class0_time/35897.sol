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

contract ERC20 is Ownable {
	function totalSupply() public view returns (uint256 totalSup);
	function balanceOf(address _owner) public view returns (uint256 balance);
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
	function allowance(address _owner, address _spender) public view returns (uint256 remaining);
	function approve(address _spender, uint256 _value) public returns (bool success);
	function transfer(address _to, uint256 _value) public returns (bool success);
	event Transfer(address indexed _from, address indexed _to, uint _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
