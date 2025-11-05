pragma solidity ^0.4.13;

contract AllowanceCrowdsale is Crowdsale {
  using SafeMath for uint256;

  address public tokenWallet;

  



  function AllowanceCrowdsale(address _tokenWallet) public {
    require(_tokenWallet != address(0));
    tokenWallet = _tokenWallet;
  }

  



  function remainingTokens() public view returns (uint256) {
    return token.allowance(tokenWallet, this);
  }

  




  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
    token.transferFrom(tokenWallet, _beneficiary, _tokenAmount);
  }
}

library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}
