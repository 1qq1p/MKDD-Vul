pragma solidity ^0.4.24;

library SafeMath {

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    if (_a == 0) {
    return 0;
    }
    uint256 c = _a * _b;
    assert(c / _a == _b);
    return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a / _b;
    return c;
    }
    
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
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

    
    function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
    }
    
    
    function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
    }

}

 
