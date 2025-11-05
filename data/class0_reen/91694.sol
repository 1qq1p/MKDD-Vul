pragma solidity 0.4.24;








contract RefundableCrowdsale is FinalizableCrowdsale {
  using SafeMath for uint256;

  
  uint256 public goal;

  
  RefundEscrow private escrow;

  



  constructor(uint256 _goal) public {
    require(_goal > 0);
    escrow = new RefundEscrow(wallet);
    goal = _goal;
  }

  


  function claimRefund() public {
    require(isFinalized);
    require(!goalReached());

    escrow.withdraw(msg.sender);
  }

  



  function goalReached() public view returns (bool) {
    return weiRaised >= goal;
  }

  


  function finalization() internal {
    if (goalReached()) {
      escrow.close();
      escrow.beneficiaryWithdraw();
    } else {
      escrow.enableRefunds();
    }

    super.finalization();
  }

  


  function _forwardFunds() internal {
    escrow.deposit.value(msg.value)(msg.sender);
  }

}







