pragma solidity ^0.4.13;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract FinalizableCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  



  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasEnded());

    finalization();
    Finalized();

    isFinalized = true;
  }

  




  function finalization() internal {
  }
}
