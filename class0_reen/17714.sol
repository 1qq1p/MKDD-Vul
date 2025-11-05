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








contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public openingTime;
  uint256 public closingTime;

  


  modifier onlyWhileOpen {
    
    require(block.timestamp >= openingTime && block.timestamp <= closingTime);
    _;
  }

  




  constructor(uint256 _openingTime, uint256 _closingTime) public {
    
    require(_openingTime >= block.timestamp);
    require(_closingTime >= _openingTime);

    openingTime = _openingTime;
    closingTime = _closingTime;
  }

  



  function hasClosed() public view returns (bool) {
    
    return block.timestamp > closingTime;
  }

  




  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
    onlyWhileOpen
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}







