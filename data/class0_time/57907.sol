pragma solidity ^0.4.18;







contract CoinBX is StandardToken, BurnableToken, Ownable, MintableToken {

  
  string  public constant name = "CoinBX";
  string  public constant symbol = "COIN";
  uint8   public constant decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 100000000 * (10 ** uint256(decimals));

  
  address public creatorAddress;

  



  function CoinBX(address _creator) public {

    
    balances[msg.sender] = INITIAL_SUPPLY;
    totalSupply_ = INITIAL_SUPPLY;

    
    creatorAddress = _creator;
  }

}