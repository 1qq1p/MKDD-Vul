pragma solidity ^0.4.4;

contract GenHeliosCoin is StandardToken {

    function () {
        
        throw;
    }

    

    





    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'H1.0';       







    function GenHeliosCoin(
        ) {
        balances[msg.sender] = 100000000000;               
        totalSupply = 100000000000;                        
        name = "Gen Helios Coin";                                   
        decimals = 2;                            
        symbol = "GHC";                               
    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        
        
        
        if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}