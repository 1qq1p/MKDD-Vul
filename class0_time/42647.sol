pragma solidity ^0.4.24;





library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }
}






contract HasOwner {
    
    address public owner;

    
    address public newOwner;

    




    constructor(address _owner) internal {
        owner = _owner;
    }

    


    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    





    event OwnershipTransfer(address indexed _oldOwner, address indexed _newOwner);

    







    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    



    function acceptOwnership() public {
        require(msg.sender == newOwner);

        emit OwnershipTransfer(owner, newOwner);

        owner = newOwner;
    }
}



