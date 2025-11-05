pragma solidity 0.4.24;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
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
    mapping(address => bool) admins;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event AddAdmin(address indexed admin);
    event DelAdmin(address indexed admin);


    



    constructor() public {
        owner = msg.sender;
    }

    


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAdmin() {
        require(isAdmin(msg.sender));
        _;
    }


    function addAdmin(address _adminAddress) external onlyOwner {
        require(_adminAddress != address(0));
        admins[_adminAddress] = true;
        emit AddAdmin(_adminAddress);
    }

    function delAdmin(address _adminAddress) external onlyOwner {
        require(admins[_adminAddress]);
        admins[_adminAddress] = false;
        emit DelAdmin(_adminAddress);
    }

    function isAdmin(address _adminAddress) public view returns (bool) {
        return admins[_adminAddress];
    }
    



    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

}

interface NewAuctionContract {
    function receiveAuction(address _token, uint _tokenId, uint _startPrice, uint _stopTime) external returns (bool);
}

