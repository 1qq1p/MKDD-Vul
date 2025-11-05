pragma solidity ^0.4.21;



contract standardToken is ERC20Token {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;

    function balanceOf(address _owner) constant public returns (uint256) {
        return balances[_owner];
    }

    
    function transfer(address _to, uint256 _value) 
        public 
        returns (bool success) 
    {
        require (balances[msg.sender] >= _value);           
        require (balances[_to] + _value >= balances[_to]);  
        balances[msg.sender] -= _value;                     
        balances[_to] += _value;                            
        emit Transfer(msg.sender, _to, _value);             
        return true;
    }

    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        allowances[msg.sender][_spender] = _value;          
        emit Approval(msg.sender, _spender, _value);        
        return true;
    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);              
        approve(_spender, _value);                                      
        spender.receiveApproval(msg.sender, _value, this, _extraData);  
        return true;
    }

    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require (balances[_from] >= _value);                
        require (balances[_to] + _value >= balances[_to]);  
        require (_value <= allowances[_from][msg.sender]);  
        balances[_from] -= _value;                          
        balances[_to] += _value;                            
        allowances[_from][msg.sender] -= _value;            
        emit Transfer(_from, _to, _value);                  
        return true;
    }

    
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }

}
