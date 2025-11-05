pragma solidity 0.4.19;
















library SafeMath {

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



contract admined { 
    address public admin; 
    bool public lockTransfer; 
    address public allowedAddress; 

    



    function admined() internal {
        admin = msg.sender; 
        allowedAddress = msg.sender; 
        Admined(admin);
        AllowedSet(allowedAddress);
    }

    modifier onlyAdmin() { 
        require(msg.sender == admin);
        _;
    }

    modifier transferLock() { 
        require(lockTransfer == false || allowedAddress == msg.sender);
        _;
    }

   



    function setAllowedAddress(address _to) onlyAdmin public {
        allowedAddress = _to;
        AllowedSet(_to);
    }

   



    function transferAdminship(address _newAdmin) onlyAdmin public { 
        require(_newAdmin != address(0)); 
        admin = _newAdmin;
        TransferAdminship(admin);
    }

   



    function setTransferLockFree() onlyAdmin public {
        require(lockTransfer == true);
        lockTransfer = false;
        SetTransferLock(lockTransfer);
    }

    
    event AllowedSet(address _to);
    event SetTransferLock(bool _set);
    event TransferAdminship(address newAdminister);
    event Admined(address administer);

}




