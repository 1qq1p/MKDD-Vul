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






contract XEVENUE is Ownable, StandardToken {

  uint8 public constant decimals = 18;
  string public constant name = "XEV";
  string public constant symbol = "XEV";
  uint256 public constant initialSupply = 1000000000 * 10 ** uint256(decimals);

  


  function XEVENUE() public {
    totalSupply = initialSupply;
    balances[msg.sender] = initialSupply;
  }

}