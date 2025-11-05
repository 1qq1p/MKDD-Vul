pragma solidity 0.4.25;
pragma experimental ABIEncoderV2;
pragma experimental "v0.5.0";






library SafeMath {

	


	function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
		
		
		
		if (a == 0) {
			return 0;
		}
		c = a * b;
		assert(c / a == b);
		return c;
	}

	


	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		
		
		
		return a / b;
	}

	


	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	


	function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
		c = a + b;
		assert(c >= a);
		return c;
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







contract Oasis {
	function getBuyAmount(ERC20 tokenToBuy, ERC20 tokenToPay, uint256 amountToPay) external view returns(uint256 amountBought);
	function getPayAmount(ERC20 tokenToPay, ERC20 tokenToBuy, uint amountToBuy) public constant returns (uint amountPaid);
	function getBestOffer(ERC20 sell_gem, ERC20 buy_gem) public constant returns(uint offerId);
	function getWorseOffer(uint id) public constant returns(uint offerId);
	function getOffer(uint id) public constant returns (uint pay_amt, ERC20 pay_gem, uint buy_amt, ERC20 buy_gem);
	function sellAllAmount(ERC20 pay_gem, uint pay_amt, ERC20 buy_gem, uint min_fill_amount) public returns (uint fill_amt);
}
