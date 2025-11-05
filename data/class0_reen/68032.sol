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
    
    uint256 c = a / b;
    
    return c;
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










contract TaoToken is BurnableToken, PausableToken {
    string public name = "TaoToken";
    string public symbol = "TT";
    uint256 public decimals = 18;
    
    uint256 public constant INITIAL_SUPPLY = 10 * 1000 * 1000 * 1000 * (10 ** uint256(decimals));

    function TaoToken() public {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
}