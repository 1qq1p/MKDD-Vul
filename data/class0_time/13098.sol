pragma solidity ^0.4.11;





contract CoupeToken is StandardToken {
	string public name = "Coupecoin Fusion"; 
  string public symbol = "CECF";
  uint256 public decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 5000000 * (10 ** uint256(decimals));
  


  function CoupeToken() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}