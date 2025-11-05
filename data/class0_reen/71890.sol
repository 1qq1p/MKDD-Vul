pragma solidity ^0.4.18;


contract TaskToken is StandardToken {

  string public constant name = "TaskToken"; 
  string public constant symbol = "TASK"; 
  uint8 public constant decimals = 18; 

  uint256 public constant INITIAL_SUPPLY = 100 * 10000 * 10000 * (10 ** uint256(decimals));

  


  function TaskToken() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }

}