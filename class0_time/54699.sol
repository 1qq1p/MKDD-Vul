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







contract FrieseCoinCrowdsale is TimedCappedMintedCrowdsale {
    constructor
        (
            uint256 _openingTime,
            uint256 _closingTime,
            uint256 _cap,
            uint256 _rate,
            address _wallet,
            MintableToken _token
        )
        TimedCappedMintedCrowdsale(_openingTime, _closingTime, _cap, _rate, _wallet, _token) public{

        }
}