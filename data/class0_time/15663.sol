pragma solidity ^0.4.18;



library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract Owned {

    address public owner;

    function Owned() public {
        owner = msg.sender;
    }

    modifier validAddress(address _address) {
        require(_address != 0x0);
        require(_address != address(this));
        _;
    }

    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public validAddress(_newOwner) onlyOwner {
        require(_newOwner != owner);

        owner = _newOwner;
    }
}

