pragma solidity ^0.4.18;





contract Eleven is StandardToken, Ownable {
  string public name = "7ELEVEN"; 
  string public symbol = "7E";
  uint256 public decimals = 8;
  uint256 public INITIAL_SUPPLY = 1000000000000 * (10 ** decimals);

  function Eleven() public {
    totalSupply_ = INITIAL_SUPPLY;
    owner = msg.sender;
    balances[msg.sender] = INITIAL_SUPPLY;
  }

}