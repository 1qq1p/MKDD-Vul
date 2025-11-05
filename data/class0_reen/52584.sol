pragma solidity ^0.4.18;







contract BftToken is DetailedERC20, CappedToken, BurnableToken, PausableToken {

	CappedCrowdsale public crowdsale;

	function BftToken(
		uint256 _tokenCap,
		uint8 _decimals,
		CappedCrowdsale _crowdsale
	)
		DetailedERC20("BF Token", "BFT", _decimals)
		CappedToken(_tokenCap) public {

		crowdsale = _crowdsale;
	}

	
	

	MintableToken public newToken = MintableToken(0x0);
	event LogRedeem(address beneficiary, uint256 amount);

	modifier hasUpgrade() {
		require(newToken != MintableToken(0x0));
		_;
	}

	function upgrade(MintableToken _newToken) onlyOwner public {
		newToken = _newToken;
	}

	
	function burn(uint256 _value) public {
		revert();
		_value = _value; 
	}

	function redeem() hasUpgrade public {

		var balance = balanceOf(msg.sender);

		
		super.burn(balance);

		
		require(newToken.mint(msg.sender, balance));
		LogRedeem(msg.sender, balance);
	}

	
	

	modifier canDoTransfers() {
		require(hasCrowdsaleFinished());
		_;
	}

	function hasCrowdsaleFinished() view public returns(bool) {
		return crowdsale.hasEnded();
	}

	function transfer(address _to, uint256 _value) public canDoTransfers returns (bool) {
		return super.transfer(_to, _value);
	}

	function transferFrom(address _from, address _to, uint256 _value) public canDoTransfers returns (bool) {
		return super.transferFrom(_from, _to, _value);
	}

	function approve(address _spender, uint256 _value) public canDoTransfers returns (bool) {
		return super.approve(_spender, _value);
	}

	function increaseApproval(address _spender, uint _addedValue) public canDoTransfers returns (bool success) {
		return super.increaseApproval(_spender, _addedValue);
	}

	function decreaseApproval(address _spender, uint _subtractedValue) public canDoTransfers returns (bool success) {
		return super.decreaseApproval(_spender, _subtractedValue);
	}

	
	

	function changeSymbol(string _symbol) onlyOwner public {
		symbol = _symbol;
	}

	function changeName(string _name) onlyOwner public {
		name = _name;
	}
}