pragma solidity ^0.4.18;


library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
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

  


  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ChainCoin is CappedToken, PausableToken, BurnableToken {

    string public constant name = "Lian Jie Token";
    string public constant symbol = "LET";
    uint8 public constant decimals = 18;

    uint256 private constant TOKEN_CAP = 100000000 * (10 ** uint256(decimals));
    uint256 private constant TOKEN_INITIAL = 100000000 * (10 ** uint256(decimals));

    function ChainCoin() public CappedToken(TOKEN_CAP) {
      totalSupply_ = TOKEN_INITIAL;

      balances[msg.sender] = TOKEN_INITIAL;
      emit Transfer(address(0), msg.sender, TOKEN_INITIAL);
  }
}