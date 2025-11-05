pragma solidity ^0.4.10;





library SafeMath {
    function mul(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }


    function transferOwnership(address newOwner) onlyOwner {
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
