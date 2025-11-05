pragma solidity ^0.4.4;

contract POMATOKEN is StandardToken {

    function () {
        
        throw;
    }

    

    





    string public name = "POMA Tokens";                   
    uint8 public decimals;                
    string public symbol = "POMA";                 
    string public version = 'H1.0';       







    function POMATOKEN(
        ) {
        balances[msg.sender] = 450000000000000000000000000;               
        totalSupply = 450000000000000000000000000;                        
        decimals = 18;                            
        symbol = "POMA";                               
    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        
        
        
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}