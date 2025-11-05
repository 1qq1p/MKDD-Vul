pragma solidity ^0.4.9;
 
contract Vdex is StandardToken {
 
    function () {
        
        throw;
    }
 
    
 
    





    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'H1.2';       
 



 

 
    function Vdex(
        ) {
        balances[msg.sender] = 100000000000000;               
        totalSupply = 100000000000000;                        
        name = "Vdex";                                   
        decimals = 8;                            
        symbol = "Vdex";                               
    }
 
    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
 
        
        
        
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}