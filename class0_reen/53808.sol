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








contract LiteXToken is StandardToken {

  string public name = "LiteXToken";
  string public symbol = "LXT";
  uint8 public decimals = 18;
  uint INITIAL_SUPPLY = 20*10**8; 

  function LiteXToken() public {
    totalSupply_ = INITIAL_SUPPLY*10**uint256(decimals);
    balances[msg.sender] = totalSupply_;
  }

  function() public payable{
    revert();
  }


}