



pragma solidity ^0.4.8;


contract GENESToken is StandardToken {

    function GENESToken() public {
        balances[msg.sender] = initialAmount;   
        totalSupply = initialAmount;            
    }

    function() public {

    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        
        
        
        
        require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }

    string public name = "GENES";
    uint8 public decimals = 18;
    string public symbol = "GENES";
    string public version = "v1.1";
    uint256 public initialAmount = 80 * (10 ** 8) * (10 ** 18);

}