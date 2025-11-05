pragma solidity ^0.4.17;






contract BurnableToken is MintableToken {
    
    using SafeMath for uint;
    
    



    function burn(uint _value) public returns (bool success) {
        require((_value > 0) && (_value <= balances[msg.sender]));
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender, _value);
        return true;
    }
 
    




    function burnFrom(address _from, uint _value) public returns (bool success) {
        require((balances[_from] > _value) && (_value <= allowed[_from][msg.sender]));
        var _allowance = allowed[_from][msg.sender];
        balances[_from] = balances[_from].sub(_value);
        totalSupply = totalSupply.sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Burn(_from, _value);
        return true;
    }

    event Burn(address indexed burner, uint indexed value);
}




