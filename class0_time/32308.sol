pragma solidity ^0.4.16;







contract FidentiaXToken is MintableToken {
  
  string public name = "fidentiaX";
  string public symbol = "fdX";
  uint256 public decimals = 18;

  
  bool public tradingStarted = false;

  


  modifier hasStartedTrading() {
    require(tradingStarted);
    _;
  }

  


  function startTrading() public onlyOwner {
    tradingStarted = true;
  }

  




  function transfer(address _to, uint _value) hasStartedTrading public returns (bool) {
    return super.transfer(_to, _value);
  }

  





  function transferFrom(address _from, address _to, uint _value) hasStartedTrading public returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function emergencyERC20Drain( ERC20 oddToken, uint amount ) public {
    oddToken.transfer(owner, amount);
  }
}


