pragma solidity ^0.4.23;





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






contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  



    constructor() public {
        owner = msg.sender;
    }

  


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

  



    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

  



    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0x0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}



