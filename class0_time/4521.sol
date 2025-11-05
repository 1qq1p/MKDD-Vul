pragma solidity ^0.4.18;






contract ICO is CommonCrowdsale {
  
  function finishMinting() public onlyOwner {
    mintExtendedTokens();
    token.finishMinting();
  }

  function createTokens() public payable saleIsOn {
    calculateAndTransferTokens();
    wallet.transfer(msg.value);
  } 

}
