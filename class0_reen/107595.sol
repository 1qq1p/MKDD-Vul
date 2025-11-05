pragma solidity ^0.4.24;






contract Bigbull is StandardToken, Burnable, Claimable {

  string public constant name = "Bigbull"; 
  string public constant symbol = "BBC"; 
  uint8 public constant decimals = 0; 

  uint256 public constant INITIAL_SUPPLY = 410000000 * (10 ** uint256(decimals));

  


  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
  }
  
}




