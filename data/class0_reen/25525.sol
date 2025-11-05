

pragma solidity ^0.4.20;

contract TEChain is StandardToken {

    function () {
        
        revert();
    }

    string public name = "Textile Chain";                   
    uint8 public decimals = 18;                
    string public symbol = "TEC";                 
    string public version = 'v0.1';       

    address public founder; 

    function TEChain() {
        founder = msg.sender;
        totalSupply = 1000000000 * 10 ** uint256(decimals);
        balances[founder] = totalSupply;
    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        
        
        
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
        return true;
    }

    
    function approveAndCallcode(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        
        if(!_spender.call(_extraData)) { revert(); }
        return true;
    }
}