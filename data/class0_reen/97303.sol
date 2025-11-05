pragma solidity ^0.4.13;
contract PotatoCoin is ERC20, SafeMath, owned{
	
	mapping(address => uint256) balances;

	uint256 public totalSupply;
    uint256 public mulFactor;

	function balanceOf(address _owner) constant returns (uint256 balance) {
	    return balances[_owner];
	}

	function transfer(address _to, uint256 _value) returns (bool success){
	    balances[msg.sender] = safeSub(balances[msg.sender], _value);
	    balances[_to] = safeAdd(balances[_to], _value);
	    Transfer(msg.sender, _to, _value);
	    return true;
	}

	mapping (address => mapping (address => uint256)) allowed;

	function transferFrom(address _from, address _to, uint256 _value) returns (bool success){
	    var _allowance = allowed[_from][msg.sender];
	
	    balances[_from] = safeSub(balances[_from], _value);
	    balances[_to] = safeAdd(balances[_to], _value);
	    allowed[_from][msg.sender] = safeSub(_allowance, _value);
	    Transfer(_from, _to, _value);
	    return true;
	}

	function approve(address _spender, uint256 _value) returns (bool success) {
	    allowed[msg.sender][_spender] = _value;
	    Approval(msg.sender, _spender, _value);
	    return true;
	}

	function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
	    return allowed[_owner][_spender];
	}
	
	
    function buy() payable { 
        uint amount=safeDiv(safeMul(msg.value,mulFactor),1 ether);
        allowed[this][msg.sender] = amount;
        transferFrom(this,msg.sender,amount);
	    
   
    }
    
    function setMulFactor(uint256 newMulFactor) onlyOwner {
        mulFactor = newMulFactor;
    }
    function addNewPotatoCoinsForSale (uint newTokens) onlyOwner {
        balances[owner] -= newTokens;
        balances[this] += newTokens;
    }
    function destroy() onlyOwner { 
      suicide(owner);
    }
    function transferFunds(address _beneficiary, uint amount) onlyOwner {
         transfer(_beneficiary,amount);
    }
    function () payable {
        uint amount=safeDiv(safeMul(msg.value,mulFactor),1 ether);
        allowed[this][msg.sender] = amount;
        transferFrom(this,msg.sender,amount);
    }

	
	string 	public name = "Potato Coin";
	string 	public symbol = "PTCN";
	uint 	public decimals = 0;
	uint 	public INITIAL_SUPPLY = 50000000;
	uint    public INITIAL_mulFactor=280;

	function PotatoCoin() {
	  totalSupply = INITIAL_SUPPLY;
	  mulFactor = INITIAL_mulFactor;
	  balances[msg.sender] = INITIAL_SUPPLY;  
	  addNewPotatoCoinsForSale (50000);
	    
	}
}