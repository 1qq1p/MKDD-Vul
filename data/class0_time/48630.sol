pragma solidity ^0.4.4;

contract MolikToken is StandardToken {

    function () {
        
        throw;
    }

    

    





    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'H1.0';       





    function MolikToken(
        ) {
        balances[msg.sender] = 1000000000000000000000000000;               
        totalSupply = 1000000000000000000000000000;                        
        name = "MolikToken";                                   
        decimals = 18;                            
        symbol = "MOL";                               
    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        
        
        
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}