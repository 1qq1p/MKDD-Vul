pragma solidity ^0.4.13;

contract MintedCrowdsale is Crowdsale {

  




  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
    require(MintableToken(token).mint(_beneficiary, _tokenAmount));
  }
}
