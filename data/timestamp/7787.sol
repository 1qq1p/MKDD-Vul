






























contract StandardTokenExt is StandardToken, Recoverable {

  
  function isToken() public constant returns (bool weAre) {
    return true;
  }
}

