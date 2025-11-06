pragma solidity ^0.4.4;

contract CorruptionCoin is StandardToken {

    function () {
        
        throw;
    }

  
    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'H1.0';       





    function CorruptionCoin(
        ) {
        balances[msg.sender] = 1000000000000;               
        totalSupply = 1000000000000;                        
        name = "CorruptionCoin";                                   
        decimals = 0;                            
        symbol = "CRTC";                               
    }

 
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        
    
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}