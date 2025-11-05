pragma solidity ^0.4.24;





library Math {
  function max64(uint64 _a, uint64 _b) internal pure returns (uint64) {
    return _a >= _b ? _a : _b;
  }

  function min64(uint64 _a, uint64 _b) internal pure returns (uint64) {
    return _a < _b ? _a : _b;
  }

  function max256(uint256 _a, uint256 _b) internal pure returns (uint256) {
    return _a >= _b ? _a : _b;
  }

  function min256(uint256 _a, uint256 _b) internal pure returns (uint256) {
    return _a < _b ? _a : _b;
  }
}





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







contract PausableToken is StandardToken, Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;
    mapping(address => bool) public whitelist;

    


    function pause() onlyOwner public {
        require(!paused);
        paused = true;
        emit Pause();
    }

    


    function unpause() onlyOwner public {
        require(paused);
        paused = false;
        emit Unpause();
    }
    




    function setWhitelisted(address who, bool allowTransfers) onlyOwner public {
        whitelist[who] = allowTransfers;
    }

    function transfer(address _to, uint256 _value) public returns (bool){
        require(!paused || whitelist[msg.sender]);
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
        require(!paused || whitelist[msg.sender] || whitelist[_from]);
        return super.transferFrom(_from, _to, _value);
    }

}




