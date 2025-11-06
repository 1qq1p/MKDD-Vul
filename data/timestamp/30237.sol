pragma solidity ^0.4.20;

contract AutoBoxToken is StandardToken {
    function () {
        
        throw;
    }
     string public name;                  
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'H1.0';       

    function AutoBoxToken(
        ) {
        balances[msg.sender] = 4500000000;               
        totalSupply = 4500000000;                        
        name = 'AutoBox';                                   
        decimals = 0;                                   
        symbol = 'AutoBox';                               
    }
    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        
        
        
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}