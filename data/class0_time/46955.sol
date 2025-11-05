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






contract IndividualCapCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  uint256 public minAmount;
  uint256 public maxAmount;

  mapping(address => uint256) public contributions;

  function IndividualCapCrowdsale(uint256 _minAmount, uint256 _maxAmount) public {
    require(_minAmount > 0);
    require(_maxAmount > _minAmount);

    minAmount = _minAmount;
    maxAmount = _maxAmount;
  }

  



  function setMinAmount(uint256 _minAmount) public onlyOwner {
    require(_minAmount > 0);
    require(_minAmount < maxAmount);

    minAmount = _minAmount;
  }

  



  function setMaxAmount(uint256 _maxAmount) public onlyOwner {
    require(_maxAmount > 0);
    require(_maxAmount > minAmount);

    maxAmount = _maxAmount;
  }

  




  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
    require(_weiAmount >= minAmount);
    super._preValidatePurchase(_beneficiary, _weiAmount);
    require(contributions[_beneficiary].add(_weiAmount) <= maxAmount);
  }

  




  function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
    super._updatePurchasingState(_beneficiary, _weiAmount);
    contributions[_beneficiary] = contributions[_beneficiary].add(_weiAmount);
  }
}









