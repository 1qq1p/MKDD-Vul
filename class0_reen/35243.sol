
pragma solidity >=0.4.10;


contract Controller is Owned, TokenReceivable, Finalizable {
	Ledger public ledger;
	Token public token;

	function Controller() {
	}

	

	function setToken(address _token) onlyOwner {
		token = Token(_token);
	}

	function setLedger(address _ledger) onlyOwner {
		ledger = Ledger(_ledger);
	}

	modifier onlyToken() {
		require(msg.sender == address(token));
		_;
	}

	modifier onlyLedger() {
		require(msg.sender == address(ledger));
		_;
	}

	

	function totalSupply() constant returns (uint) {
		return ledger.totalSupply();
	}

	function balanceOf(address _a) constant returns (uint) {
		return ledger.balanceOf(_a);
	}

	function allowance(address _owner, address _spender) constant returns (uint) {
		return ledger.allowance(_owner, _spender);
	}

	

	
	
	
	function ledgerTransfer(address from, address to, uint val) onlyLedger {
		token.controllerTransfer(from, to, val);
	}

	

	function transfer(address _from, address _to, uint _value) onlyToken returns (bool success) {
		return ledger.transfer(_from, _to, _value);
	}

	function transferFrom(address _spender, address _from, address _to, uint _value) onlyToken returns (bool success) {
		return ledger.transferFrom(_spender, _from, _to, _value);
	}

	function approve(address _owner, address _spender, uint _value) onlyToken returns (bool success) {
		return ledger.approve(_owner, _spender, _value);
	}

	function increaseApproval (address _owner, address _spender, uint _addedValue) onlyToken returns (bool success) {
		return ledger.increaseApproval(_owner, _spender, _addedValue);
	}

	function decreaseApproval (address _owner, address _spender, uint _subtractedValue) onlyToken returns (bool success) {
		return ledger.decreaseApproval(_owner, _spender, _subtractedValue);
	}

	function burn(address _owner, uint _amount) onlyToken {
		ledger.burn(_owner, _amount);
	}

	

	
	mapping (address => uint) public whitelist;
	mapping (address => uint) public exchg;

	function addToWhitelist(address addr, uint rate, uint weimax) onlyOwner {
		exchg[addr] = rate;
		whitelist[addr] = weimax;
	}

	
	function fallback(address orig) payable onlyToken {
		uint max = whitelist[orig];
		uint denom = exchg[orig];
		require(denom != 0);
		require(msg.value <= max);
		whitelist[orig] = max - msg.value;
		uint tkn = msg.value / denom;
		ledger.controllerMint(orig, tkn);
		token.controllerTransfer(0, orig, tkn);
	}
}
