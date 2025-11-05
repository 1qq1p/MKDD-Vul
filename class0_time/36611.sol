pragma solidity ^0.4.18;







contract ILMTToken is StandardToken {

  string public constant name = "The Illuminati Token";
  string public constant symbol = "ILMT";
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 33000000 * (10 ** uint256(decimals));

  


  function ILMTToken() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }

}