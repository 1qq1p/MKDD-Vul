pragma solidity ^0.4.11;


library SafeMath {
  function mul(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) pure internal returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract TTCoin is StandardToken {

  string public constant name = "TTCoin";
  string public constant symbol = "TTC";
  uint8 public constant decimals = 4;

  uint256 public constant INITIAL_SUPPLY = 15000000 * (10 ** uint256(decimals));


  function TTCoin() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }

}