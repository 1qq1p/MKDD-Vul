contract Token {

    
    function totalSupply() constant returns (uint256 supply) {}

    
    
    function balanceOf(address _owner) constant returns (uint256 balance) {}

    
    
    
    
    function transfer(address _to, uint256 _value) returns (bool success) {}

    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    
    
    
    
    function approve(address _spender, uint256 _value) returns (bool success) {}

    
    
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}



contract ERC20Token is StandardToken {

    function () {
        
        throw;
    }

    

    





    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'H1.0';       







    function ERC20Token(
        ) {
        balances[msg.sender] = 20000000000000000000000000;               
        totalSupply = 20000000000000000000000000;                        
        name = "HunterCoin";                                   
        decimals = 18;                            
        symbol = "HTC";                               
    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        
        
        
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}