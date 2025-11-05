pragma solidity ^0.4.18;

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
		decimals = 18;                            
		totalSupply = 2000000000 * 10 ** uint256(decimals); 
        balances[msg.sender] = totalSupply;               
        name = "ETGG";                                   
        symbol = "ETGG";                               
    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        
        
        
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}