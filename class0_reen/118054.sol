pragma solidity ^0.4.4;

contract JOKE is StandardToken {

    

    





    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'H1.0';       


    constructor() public {
        balances[msg.sender] = 250000000;               
        totalSupply = 250000000;                        
        name = "JUST JOKIN TOKEN";                                   
        decimals = 0;                            
        symbol = "JOKE";                               
    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        
        
        
        if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
        return true;
    }
}