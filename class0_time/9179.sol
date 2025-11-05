pragma solidity ^0.4.24;






contract GlobalSuperGameCoin is StandardToken {
  string public name = "Global Super Game";
  string public symbol = "GSG";
  uint8 public decimals = 10;
  uint256 public INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));
  uint256 public totalSupply;

  constructor() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}