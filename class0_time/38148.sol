pragma solidity ^0.4.8;





contract Lotto is Owned {

  address[] public previousRounds;

  LotteryGameLogicInterface public gameLogic;

  modifier onlyWhenUpgradeable {
    if (!gameLogic.isUpgradeAllowed()) {
      throw;
    }
    _;
  }

  modifier onlyGameLogic {
    if (msg.sender != address(gameLogic)) {
      throw;
    }
    _;
  }

  



  function Lotto(address initialGameLogic) {
    gameLogic = LotteryGameLogicInterface(initialGameLogic);
  }

  





  function setNewGameLogic(address newLogic) onlyOwner onlyWhenUpgradeable {
    gameLogic.transferOwnership(owner);
    gameLogic = LotteryGameLogicInterface(newLogic);
  }

  



  function currentRound() constant returns(address) {
    return gameLogic.currentRound();
  }

  



  function finalizeRound() onlyOwner {
    address roundAddress = gameLogic.finalizeRound();
    previousRounds.push(roundAddress);
  }

  


  function previousRoundsCount() constant returns(uint) {
    return previousRounds.length;
  }

  
  
  
  function () {
    throw;
  }
}