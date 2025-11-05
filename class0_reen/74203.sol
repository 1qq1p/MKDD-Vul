

pragma solidity ^0.4.18;







contract McoToken is StandardToken, BurnableToken, Ownable {
	string public constant symbol = "mco";
	string public constant name = "matching coin";
	uint8 public constant decimals = 18;
	uint256 public constant INITIAL_SUPPLY = 12500000000 * (10 ** uint256(decimals));
	uint256 public constant TOKEN_OFFERING_ALLOWANCE = 5000000000 * (10 ** uint256(decimals));
	uint256 public constant ADMIN_ALLOWANCE = INITIAL_SUPPLY - TOKEN_OFFERING_ALLOWANCE;

	
	address public adminAddr;
	
	address public tokenOfferingAddr;
	
	bool public transferEnabled = true;

	








	modifier onlyWhenTransferAllowed() {
		require(transferEnabled || msg.sender == adminAddr || msg.sender == tokenOfferingAddr);
		_;
	}

	


	modifier onlyTokenOfferingAddrNotSet() {
		require(tokenOfferingAddr == address(0x0));
		_;
	}

	







	modifier validDestination(address to) {
		require(to != address(0x0));
		require(to != address(this));
		require(to != owner);
		require(to != address(adminAddr));
		require(to != address(tokenOfferingAddr));
		_;
	}	

	




	function McoToken(address admin) public {
		totalSupply_ = INITIAL_SUPPLY;

		
		balances[msg.sender] = totalSupply_;
		Transfer(address(0x0), msg.sender, totalSupply_);

		
		adminAddr = admin;
		approve(adminAddr, ADMIN_ALLOWANCE);
	}

	





	function setTokenOffering(address offeringAddr, uint256 amountForSale) external onlyOwner onlyTokenOfferingAddrNotSet {
		require(!transferEnabled);

		uint256 amount = (amountForSale == 0) ? TOKEN_OFFERING_ALLOWANCE : amountForSale;
		require(amount <= TOKEN_OFFERING_ALLOWANCE);

		approve(offeringAddr, amount);
		tokenOfferingAddr = offeringAddr;
	}

	


	function enableTransfer() external onlyOwner {
		transferEnabled = true;

		
		approve(tokenOfferingAddr, 0);
	}

	





	function transfer(address to, uint256 value) public onlyWhenTransferAllowed validDestination(to) returns (bool) {
		return super.transfer(to, value);
	}

	






	function transferFrom(address from, address to, uint256 value) public onlyWhenTransferAllowed validDestination(to) returns (bool) {
		return super.transferFrom(from, to, value);
	}

	




	function burn(uint256 value) public {
		require(transferEnabled || msg.sender == owner);
		super.burn(value);
	}
}