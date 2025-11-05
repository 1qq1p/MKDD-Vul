pragma solidity ^0.4.16;

contract StarToken is Owned, StandardToken {

    string public standard = "Token 0.1";

    string public name = "StarLight";        
    
    string public symbol = "STAR";

    uint8 public decimals = 8;
   
    function StarToken() {  
        balances[msg.sender] = 0;
        totalSupply = 0;
        locked = false;
    }
   
    function unlock() onlyOwner returns (bool success)  {
        locked = false;
        return true;
    }
    
    function lock() onlyOwner returns (bool success)  {
        locked = true;
        return true;
    }
    
    

    function issue(address _recipient, uint256 _value) onlyICO returns (bool success) {

        require(_value >= 0);

        balances[_recipient] += _value;
        totalSupply += _value;

        Transfer(0, owner, _value);
        Transfer(owner, _recipient, _value);

        return true;
    }
   
    function () {
        throw;
    }
}