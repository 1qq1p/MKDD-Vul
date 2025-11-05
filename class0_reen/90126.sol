pragma solidity ^0.4.23;















contract Whitelist is Ownable {
    mapping(address => bool) public whitelist;

    mapping(uint  => address)   whitelistCheck;
    uint public countAddress = 0;

    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);
 
  


    modifier onlyWhitelisted() {
        require(whitelist[msg.sender]);
        _;
    }

    constructor() public {
            whitelist[msg.sender] = true;  
            whitelist[this] = true;  
    }

  




    function addAddressToWhitelist(address addr) onlyWhitelisted public returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;

            countAddress = countAddress + 1;
            whitelistCheck[countAddress] = addr;

            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

    function getWhitelistCheck(uint key) onlyWhitelisted view public returns(address) {
        return whitelistCheck[key];
    }


    function getInWhitelist(address addr) public view returns(bool) {
        return whitelist[addr];
    }
    function getOwnerCEO() public onlyWhitelisted view returns(address) {
        return ownerCEO;
    }
 
    





    function addAddressesToWhitelist(address[] addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    





    function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }

    





    function removeAddressesFromWhitelist(address[] addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
    }
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
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
 
