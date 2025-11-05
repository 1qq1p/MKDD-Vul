pragma solidity 0.5.4;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        uint256 c = a / b;
        
        return c;       
    }       

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}

contract Whitelist is Ownable {
    using SafeMath for uint256;

    mapping (address => bool) public whitelist;
    
    event AddWhiteListAddress(address indexed _address);
    event RemoveWhiteListAddress(address indexed _address);


    constructor() public {
        whitelist[owner] = true;
    }
    
    function AddWhitelist(address account) public onlyOwner returns(bool) {
        require(account != address(0));
        require(whitelist[account] == false);
        require(account != address(this));
        whitelist[account] = true;
        emit AddWhiteListAddress(account);
        return true;
    }

    function RemoveWhiltelist(address account) public onlyOwner returns(bool) {
        require(account != address(0));
        require(whitelist[account] == true);
        require(account != owner);
        whitelist[account] = false;
        emit RemoveWhiteListAddress(account);
        return true;
    }
}
