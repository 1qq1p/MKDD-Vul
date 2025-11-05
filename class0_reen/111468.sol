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
 





contract DickTokenCrowdsale is CappedCrowdsale {
 
 function DickTokenCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _cap, address _wallet) public
    CappedCrowdsale(_cap)
    Crowdsale(_startTime, _endTime, _rate, _wallet)
  {
  }
 
  function createTokenContract() internal returns (MintableToken) {
    MintableToken pcoin = new DickToken();
   
 
    pcoin.mint(0xA6fD40Bf56c0D1776A7b3D9165A069DA31Ae3035, 1000000000000000000000000);
    return pcoin;
  }
 
}