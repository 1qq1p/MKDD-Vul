pragma solidity ^0.4.21;







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








contract DiscountedPreICO is TimedCrowdsale {
  using SafeMath for uint256;
  
  function DiscountedPreICO(uint256 _opening_time, uint256 _closing_time) 
      TimedCrowdsale(_opening_time, _closing_time) public {
  }
  
  
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
     return _weiAmount.mul(rate).mul(100).div(100 - getCurrentDiscount());
  }
  
  


  function getCurrentDiscount() public view returns(uint256) {
    return 0;
  }
}
