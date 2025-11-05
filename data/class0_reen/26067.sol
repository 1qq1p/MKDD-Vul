pragma solidity 0.4.25;
pragma experimental ABIEncoderV2;
pragma experimental "v0.5.0";






library SafeMath {
	int256 constant private INT256_MIN = -2**255;

	


	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		
		
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b);

		return c;
	}

	


	function mul(int256 a, int256 b) internal pure returns (int256) {
		
		
		if (a == 0) {
			return 0;
		}

		require(!(a == -1 && b == INT256_MIN)); 

		int256 c = a * b;
		require(c / a == b);

		return c;
	}

	


	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		
		require(b > 0);
		uint256 c = a / b;
		

		return c;
	}

	


	function div(int256 a, int256 b) internal pure returns (int256) {
		require(b != 0); 
		require(!(b == -1 && a == INT256_MIN)); 

		int256 c = a / b;

		return c;
	}

	


	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b <= a);
		uint256 c = a - b;

		return c;
	}

	


	function sub(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a - b;
		require((b >= 0 && c <= a) || (b < 0 && c > a));

		return c;
	}

	


	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a);

		return c;
	}

	


	function add(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a + b;
		require((b >= 0 && c >= a) || (b < 0 && c < a));

		return c;
	}

	


	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b != 0);
		return a % b;
	}
}






library SafeMathFixedPoint {
	using SafeMath for uint256;

	function mul27(uint256 x, uint256 y) internal pure returns (uint256 z) {
		z = x.mul(y).add(5 * 10**26).div(10**27);
	}
	function mul18(uint256 x, uint256 y) internal pure returns (uint256 z) {
		z = x.mul(y).add(5 * 10**17).div(10**18);
	}

	function div18(uint256 x, uint256 y) internal pure returns (uint256 z) {
		z = x.mul(10**18).add(y.div(2)).div(y);
	}
	function div27(uint256 x, uint256 y) internal pure returns (uint256 z) {
		z = x.mul(10**27).add(y.div(2)).div(y);
	}
}







contract Claimable is Ownable {
	address public pendingOwner;

	


	modifier onlyPendingOwner() {
		require(msg.sender == pendingOwner);
		_;
	}

	



	function transferOwnership(address newOwner) onlyOwner public {
		pendingOwner = newOwner;
	}

	


	function claimOwnership() onlyPendingOwner public {
		emit OwnershipTransferred(owner, pendingOwner);
		owner = pendingOwner;
		pendingOwner = address(0);
	}
}





