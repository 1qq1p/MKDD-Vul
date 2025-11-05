pragma solidity 0.4.24;







library SafeMath {

  


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    
    
    
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  


  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
    return _a / _b;
  }

  


  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  


  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}








contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  


  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  


  modifier whenPaused() {
    require(paused);
    _;
  }

  


  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  


  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}






interface ICrowdsale {
    function kyc(address _address) external returns (bool);
    function wallet() external returns (address);
    function minContribution() external returns (uint256);
    function getCurrentRate() external returns (uint256);
}




interface IToken {
    function mint(address _to, uint256 _amount) external returns (bool);
}




