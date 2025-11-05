pragma solidity ^0.4.20;

contract ArcBlock is StandardToken {

    function () {
        
        throw;
    }

    

    





    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'H1.0';       







    function ArcBlock(
        ) {
        balances[msg.sender] = 186000000000000000000000000;               
        totalSupply = 186000000000000000000000000;                        
        name = "ArcBlock";                                   
        decimals = 18;                            
        symbol = "ABT";                               
    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        
        
        
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}