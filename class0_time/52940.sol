











pragma solidity 0.4.21;


library StringUtil {
    function stringToBytes12(string str)
        internal
        pure
        returns (bytes12 result)
    {
        assembly {
            result := mload(add(str, 32))
        }
    }
    function stringToBytes10(string str)
        internal
        pure
        returns (bytes10 result)
    {
        assembly {
            result := mload(add(str, 32))
        }
    }
    
    function checkStringLength(string name, uint min, uint max)
        internal
        pure
        returns (bool)
    {
        bytes memory temp = bytes(name);
        return temp.length >= min && temp.length <= max;
    }
}














library AddressUtil {
    function isContract(address addr)
        internal
        view
        returns (bool)
    {
        if (addr == 0x0) {
            return false;
        } else {
            uint size;
            assembly { size := extcodesize(addr) }
            return size > 0;
        }
    }
}







































contract Ownable {
    address public owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    
    
    function Ownable() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    
    
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != 0x0);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


