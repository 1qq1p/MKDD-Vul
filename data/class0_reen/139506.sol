



contract BurnableToken is StandardToken {

  address public constant BURN_ADDRESS = 0;

  
  event Burned(address burner, uint burnedAmount);

  



  function burn(uint burnAmount) {
    address burner = msg.sender;
    balances[burner] = safeSub(balances[burner], burnAmount);
    totalSupply = safeSub(totalSupply, burnAmount);
    Burned(burner, burnAmount);
  }
}










