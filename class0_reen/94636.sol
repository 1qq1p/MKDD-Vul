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

 

contract Ownable {
    address public owner;
    address public newOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
    owner = msg.sender;
    newOwner = address(0);
    }

    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
    }

    modifier onlyNewOwner() {
    require(msg.sender != address(0));
    require(msg.sender == newOwner);
    _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    newOwner = _newOwner;
    }
    
    function acceptOwnership() public onlyNewOwner returns(bool) {
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    }
}

