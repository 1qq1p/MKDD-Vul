











pragma solidity 0.4.21;



library MathUint8 {
    function xorReduce(
        uint8[] arr,
        uint    len
        )
        internal
        pure
        returns (uint8 res)
    {
        res = arr[0];
        for (uint i = 1; i < len; i++) {
            res ^= arr[i];
        }
    }
}














library MathUint {
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a);
        return a - b;
    }
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function tolerantSub(uint a, uint b) internal pure returns (uint c) {
        return (a >= b) ? a - b : 0;
    }
    
    
    function cvsquare(
        uint[] arr,
        uint scale
        )
        internal
        pure
        returns (uint)
    {
        uint len = arr.length;
        require(len > 1);
        require(scale > 0);
        uint avg = 0;
        for (uint i = 0; i < len; i++) {
            avg += arr[i];
        }
        avg = avg / len;
        if (avg == 0) {
            return 0;
        }
        uint cvs = 0;
        uint s;
        uint item;
        for (i = 0; i < len; i++) {
            item = arr[i];
            s = item > avg ? item - avg : avg - item;
            cvs += mul(s, s);
        }
        return ((mul(mul(cvs, scale), scale) / avg) / avg) / (len - 1);
    }
}















library MathBytes32 {
    function xorReduce(
        bytes32[]   arr,
        uint        len
        )
        internal
        pure
        returns (bytes32 res)
    {
        res = arr[0];
        for (uint i = 1; i < len; i++) {
            res ^= arr[i];
        }
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



























contract Claimable is Ownable {
    address public pendingOwner;
    
    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner);
        _;
    }
    
    
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != 0x0 && newOwner != owner);
        pendingOwner = newOwner;
    }
    
    function claimOwnership() onlyPendingOwner public {
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = 0x0;
    }
}



