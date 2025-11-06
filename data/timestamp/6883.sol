pragma solidity ^0.4.13;

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

contract MenloTokenReceiver {

    


    MenloToken token;

    constructor(MenloToken _tokenContract) public {
        token = _tokenContract;
    }

    


    bytes4 internal constant ONE_RECEIVED = 0x150b7a03;

    


    modifier onlyTokenContract() {
        require(msg.sender == address(token));
        _;
    }

    













    function onTokenReceived(
        address _from,
        uint256 _value,
        uint256 _action,
        bytes _data
    ) public  returns(bytes4);
}