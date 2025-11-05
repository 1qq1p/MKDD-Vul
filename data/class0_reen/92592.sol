pragma solidity ^0.4.24;

contract INCH is StandardToken {

    function () {
        throw;
    }

    

    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'H1.0';    


    function INCH(
        ) {
        balances[msg.sender] = 105324821468000000000000000000;
        totalSupply = 105324821468000000000000000000;
        name = "Interstellar Chain";
        decimals = 18;
        symbol = "INCH";
    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        
        
        
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}