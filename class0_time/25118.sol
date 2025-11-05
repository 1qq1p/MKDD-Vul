pragma solidity 0.4.19;







contract BurnableToken is StandardToken, Ownable {

    event Burn(address indexed burner, uint256 value);

    



    function burn(uint256 _value) public onlyOwner {
        require(_value > 0);
        require(_value <= balances[msg.sender]);
        
        

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
}

