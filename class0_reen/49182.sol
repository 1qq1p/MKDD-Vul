pragma solidity ^0.4.18;








contract PercentRateFeature is Ownable, PercentRateProvider {

  function setPercentRate(uint newPercentRate) public onlyOwner {
    percentRate = newPercentRate;
  }

}


