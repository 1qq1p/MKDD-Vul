pragma solidity ^0.4.18;





contract WhitelistSale is AbstractSale, Whitelist {
	function checkPurchaseValid(address buyer, uint256 sold, uint256 bonus) internal {
		super.checkPurchaseValid(buyer, sold, bonus);
		require(isInWhitelist(buyer));
	}
}
