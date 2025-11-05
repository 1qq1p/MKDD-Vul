pragma solidity ^0.4.21;


contract RefundableCrowdsale is StagebleCrowdsale {
  using SafeMath for uint256;

  
  uint256 public goal;

  
  RefundVault public vault;
  
  address advWallet;
  uint256 advPercent;
  bool advIsCalc = false;

  



  function RefundableCrowdsale(uint256 _goal, uint256 _advPercent) public {
    require(_goal > 0);
    vault = new RefundVault(wallet);
    goal = _goal;
    advPercent = _advPercent;
  }

  


  function claimRefund() public {
    require(isFinalized);
    require(!goalReached());

    vault.refund(msg.sender);
  }

  



  function goalReached() public view returns (bool) {
    return weiRaised >= goal;
  }

  


  function finalization() internal {
    if (goalReached()) {
        vault.close();
    } else {
      vault.enableRefunds();
    }

    super.finalization();
  }

  


  function _forwardFunds() internal {
    vault.deposit.value(msg.value)(msg.sender);
    if(!advIsCalc &&_getInStageIndex () > 0 && goalReached() && advWallet != address(0))
    {
        
        uint256 advAmount = 0;
        advIsCalc = true;
        advAmount = weiRaised.mul(advPercent).div(100);
        vault.depositAdvisor(advWallet, advAmount);
    }
  }
  
  function onlyOwnerSetAdvWallet(address _advWallet) public onlyOwner{
      require(_advWallet != address(0));
      advWallet = _advWallet;
  }
  function onlyOwnerGetAdvWallet() onlyOwner public view returns(address){
          return advWallet;
    }

}


