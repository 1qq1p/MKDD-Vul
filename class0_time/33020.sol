pragma solidity ^0.4.11;






contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) {
    require(_cap > 0);
    cap = _cap * 1000000000000000000;
  }

  
  
  function validPurchase() internal constant returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

  
  
  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}





