pragma solidity ^0.4.16;





library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}






contract Paygine is BurnableToken {
  event PaygineHasDeployed(uint time);

  string public constant name = "Paygine";
  string public constant symbol = "PGC";
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 151750000 * (10 ** uint256(decimals));

  


  function Paygine() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    PaygineHasDeployed(now);
  }
}