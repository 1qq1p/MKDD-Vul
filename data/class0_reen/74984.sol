pragma solidity ^0.4.21;





contract TokenBase is ERC20Interface, Pausable, SafeMath {
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 internal _totalSupply;
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping (address => bool) public frozenAccount;

    event FrozenFunds(address target, bool frozen);
    event Burn(address indexed from, uint256 value);
    
    
    
    
    function totalSupply() public constant returns (uint256) {
        return _totalSupply;
    }
    
    
    
    
    function balanceOf(address tokenOwner) public constant returns (uint256 balance) {
        return balances[tokenOwner];
    }
    
    
    
    
    
    function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }


    


    function _transfer(address _from, address _to, uint256 _value) internal whenNotPaused returns (bool success) {
        require(_to != 0x0);                
        require(balances[_from] >= _value);            
        require(!frozenAccount[_from]);                     
        require(!frozenAccount[_to]);                       
        require( SafeMath.safeAdd(balances[_to], _value) > balances[_to]);          
        uint256 previousBalances =  SafeMath.safeAdd(balances[_from], balances[_to]);
        balances[_from] = SafeMath.safeSub(balances[_from], _value);      
        balances[_to] = SafeMath.safeAdd(balances[_to], _value);          
        assert(balances[_from] + balances[_to] == previousBalances);
        emit Transfer(_from, _to, _value);
        return true;
    }

    


    function transfer(address _to, uint256 _value) public returns (bool success){
        _transfer(msg.sender, _to, _value);
        return true;
    }

    


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowed[_from][msg.sender]);     
        allowed[_from][msg.sender] = SafeMath.safeSub(allowed[_from][msg.sender], _value);
        _transfer(_from, _to, _value);
        return true;
    }

    
    function approve(address spender, uint256 tokens) public whenNotPaused returns (bool success) {
        require(tokens >= 0);
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public whenNotPaused returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    


    
    function burn(uint256 _value) public onlyOwner whenNotPaused returns (bool success) {
		require(balances[msg.sender] >= _value);
		require(_value > 0);
        balances[msg.sender] = SafeMath.safeSub(balances[msg.sender], _value);            
        _totalSupply = SafeMath.safeSub(_totalSupply, _value);                                
        emit Burn(msg.sender, _value);
        return true;
    }

    


    function burnFrom(address _from, uint256 _value) public onlyOwner whenNotPaused returns (bool success) {
        require(balances[_from] >= _value);                
        require(_value <= allowed[_from][msg.sender]);    
        balances[_from] = SafeMath.safeSub(balances[_from], _value);    
        allowed[_from][msg.sender] = SafeMath.safeSub(allowed[_from][msg.sender], _value);  
        _totalSupply = SafeMath.safeSub(_totalSupply,_value);  
        emit Burn(_from, _value);
        return true;
    }
}
