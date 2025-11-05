pragma solidity 0.4.17;







contract FinalizableCrowdsale is Crowdsale {
  using SafeMath for uint256;

  bool isFinalized = false;

  event Finalized();

  



  function finalizeCrowdsale() onlyOwner public {
    require(!isFinalized);
    require(hasEnded());
    
    finalization();
    Finalized();
    
    isFinalized = true;
    }
  

  




  function finalization() internal {
  }
}











