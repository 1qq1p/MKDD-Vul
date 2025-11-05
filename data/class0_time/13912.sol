
pragma solidity ^0.4.23;

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

contract Controller {

	address public owner;

	modifier onlyOwner {
    	require(msg.sender == owner);
    	_;
  	}

  	function change_owner(address new_owner) onlyOwner {
    	require(new_owner != 0x0);
    	owner = new_owner;
  	}

  	function Controller() {
    	owner = msg.sender;
  	}
}
