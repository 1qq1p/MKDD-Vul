



































pragma solidity ^0.4.11;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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

contract ENDOairdrop {
  using SafeMath for uint256;

  ETokenPromo public token;
  
  uint256 public currentTokenCount;
  address public owner;
  uint256 public maxTokenCount;

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  function ENDOairdrop() public {
    token = createTokenContract();
    owner = msg.sender;
  }
  
  function sendToken(address[] recipients, uint256 value) public {
    for (uint256 i = 0; i < recipients.length; i++) {
      token.mint(recipients[i], value);
    }
  }

  function createTokenContract() internal returns (ETokenPromo) {
    return new ETokenPromo();
  }

}