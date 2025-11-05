pragma solidity ^0.4.15;






contract FypToken is MintableToken, LimitedTransferToken {

  string public constant name = "Flyp.me Token";
  string public constant symbol = "FYP";
  uint8 public constant decimals = 18;
  bool public isTransferable = false;

  function enableTransfers() onlyOwner {
     isTransferable = true;
  }

  function transferableTokens(address holder, uint64 time) public constant returns (uint256) {
    if (!isTransferable) {
        return 0;
    }
    return super.transferableTokens(holder, time);
  }

  function finishMinting() onlyOwner public returns (bool) {
     enableTransfers();
     return super.finishMinting();
  }

}