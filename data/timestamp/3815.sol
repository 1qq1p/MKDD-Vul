pragma solidity ^0.4.24;

library DataSet {

    enum RoundState {
        UNKNOWN,        
        STARTED,        
        STOPPED,        
        DRAWN,          
        ASSIGNED        
    }

    struct Round {
        uint256                         count;              
        uint256                         timestamp;          
        uint256                         blockNumber;        
        uint256                         drawBlockNumber;    
        RoundState                      state;              
        uint256                         pond;               
        uint256                         winningNumber;      
        address                         winner;             
    }

}





library NumberCompressor {

    uint256 constant private MASK = 16777215;   

    function encode(uint256 _begin, uint256 _end, uint256 _ceiling) internal pure returns (uint256)
    {
        require(_begin <= _end && _end < _ceiling, "number is invalid");

        return _begin << 24 | _end;
    }

    function decode(uint256 _value) internal pure returns (uint256, uint256)
    {
        uint256 end = _value & MASK;
        uint256 begin = (_value >> 24) & MASK;
        return (begin, end);
    }

}











library SafeMath {

    


    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        uint256 c = a / b;
        
        return c;
    }

    


    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    


    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }

    


    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y)
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y)
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }

    


    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }

    


    function pwr(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }

    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
}

contract UpgradeabilityProxy is Proxy {
    



    event Upgraded(address indexed implementation);

    
    bytes32 private constant implementationPosition = keccak256("you are the lucky man.proxy");

    


    constructor() public {}

    



    function implementation() public view returns (address impl) {
        bytes32 position = implementationPosition;
        assembly {
            impl := sload(position)
        }
    }

    



    function setImplementation(address newImplementation) internal {
        bytes32 position = implementationPosition;
        assembly {
            sstore(position, newImplementation)
        }
    }

    



    function _upgradeTo(address newImplementation) internal {
        address currentImplementation = implementation();
        require(currentImplementation != newImplementation, "new address is the same");
        setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }
}




