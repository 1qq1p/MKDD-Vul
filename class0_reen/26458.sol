pragma solidity ^0.4.24;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = add(x, 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = add((x / z), z) / 2;
        }
    }

    function sq(uint256 x) internal pure returns (uint256) {
        return mul(x, x);
    }

    function pwr(uint256 x, uint256 y) internal pure returns (uint256) {
        if (x == 0) {
            return 0;
        }
        if (y == 0) {
            return 1;
        }
        uint256 z = x;
        for (uint256 i=1; i < y; i++) {
            z = mul(z,x);
        }
        return (z);
    }
}

library NameFilter {
    function nameFilter(string _input) internal pure returns(bytes32) {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;

        require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
        require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");
        if (_temp[0] == 0x30) {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }

        bool _hasNonNumber;

        for (uint256 i = 0; i < _length; i++) {
            if (_temp[i] > 0x40 && _temp[i] < 0x5b) {
                _temp[i] = byte(uint(_temp[i]) + 32);

                if (_hasNonNumber == false) {
                    _hasNonNumber = true;
                }
            } else {
                require(_temp[i] == 0x20 || (_temp[i] > 0x60 && _temp[i] < 0x7b) || (_temp[i] > 0x2f && _temp[i] < 0x3a), "string contains invalid characters");
                if (_temp[i] == 0x20) {
                    require( _temp[i+1] != 0x20, "string cannot contain consecutive spaces");
                }

                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39)) {
                    _hasNonNumber = true;
                }
            }
        }

        require(_hasNonNumber == true, "string cannot be only numbers");

        bytes32 _ret;
        assembly {
            _ret := mload(add(_temp, 32))
        }

        return (_ret);
    }
}

library F3Ddatasets {
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    struct EventReturns {
        uint256 compressedData;
        uint256 compressedIDs;
        address winnerAddr;         
        bytes32 winnerName;         
        uint256 amountWon;          
        uint256 newPot;             
        uint256 genAmount;          
        uint256 potAmount;          
    }

    struct Player {
        address addr;   
        bytes32 name;   
        uint256 win;    
        uint256 gen;    
        uint256 aff;    
        uint256 lrnd;   
        uint256 laff;   
    }

    struct PlayerRounds {
        uint256 eth;    
        uint256 keys;   
        uint256 mask;   
        uint256 ico;    
    }

    struct Round {
        uint256 plyr;   
        uint256 team;   
        uint256 end;    
        bool ended;     
        uint256 strt;   
        uint256 keys;   
        uint256 eth;    
        uint256 pot;    
        uint256 mask;   
        uint256 ico;    
        uint256 icoGen; 
        uint256 icoAvg; 
    }
}

library F3DKeysCalcLong {
    using SafeMath for *;

    function keysRec(uint256 _curEth, uint256 _newEth) internal pure returns (uint256) {
        return(keys((_curEth).add(_newEth)).sub(keys(_curEth)));
    }

    function ethRec(uint256 _curKeys, uint256 _sellKeys) internal pure returns (uint256) {
        return((eth(_curKeys)).sub(eth(_curKeys.sub(_sellKeys))));
    }

    function keys(uint256 _eth) internal pure returns(uint256) {
        return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
    }

    function eth(uint256 _keys) internal pure returns(uint256) {
        return ((78125000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
    }
}

interface PartnershipInterface {
    function deposit() external payable returns(bool);
}

interface PlayerBookInterface {
    function getPlayerID(address _addr) external returns (uint256);
    function getPlayerName(uint256 _pID) external view returns (bytes32);
    function getPlayerLAff(uint256 _pID) external view returns (uint256);
    function getPlayerAddr(uint256 _pID) external view returns (address);
    function getNameFee() external view returns (uint256);
    function registerNameXIDFromDapp(address _addr, bytes32 _name, uint256 _affCode, bool _all) external payable returns(bool, uint256);
    function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode, bool _all) external payable returns(bool, uint256);
    function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode, bool _all) external payable returns(bool, uint256);
}

interface ExternalSettingsInterface {
    function getLongGap() external returns(uint256);
    function getLongExtra() external returns(uint256);
    function updateLongExtra(uint256 _pID) external;
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not owner.");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address.");

        owner = _newOwner;

        emit OwnershipTransferred(owner, _newOwner);
    }
}
