pragma solidity ^0.4.17;












library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}






contract Owned {
    
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = 0x0567cB7c5A688401Aab87093058754E096C4d37E;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0x0));
        emit OwnershipTransferred(owner,_newOwner);
        owner = _newOwner;
    }
    
}




