pragma solidity ^0.4.16;






contract Presscoins is BurnableToken {

  string public constant name = "Presscoins";

  string public constant symbol = "PRESS";

  uint32 public constant decimals = 18;

  uint256 public INITIAL_SUPPLY = 100000000 * 1 ether;

  function Presscoins() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }

}
