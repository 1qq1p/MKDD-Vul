pragma solidity ^0.4.15;








contract CappedCrowdsale is GenericCrowdsale {

  
  uint public weiFundingCap = 0;

  
  event FundingCapSet(uint newFundingCap);


  







  function setFundingCap(uint newCap) internal onlyOwner notFinished {
    weiFundingCap = newCap;
    require(weiFundingCap >= minimumFundingGoal);
    FundingCapSet(weiFundingCap);
  }
}





