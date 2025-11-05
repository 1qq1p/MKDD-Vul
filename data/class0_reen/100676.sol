pragma solidity ^0.5.7;





library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns(uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract owned {
    
    address payable internal owner;
    address payable internal newOwner;
    address payable internal found;
    address payable internal feedr;
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    function changeOwner(address payable _owner) onlyOwner public {
        require(_owner != address(0));
        newOwner = _owner;
    }

    function confirmOwner() public {
        require(newOwner == msg.sender);
        owner = newOwner;
        delete newOwner;
    }
}
