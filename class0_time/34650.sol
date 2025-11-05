pragma solidity 0.4.20;



















library SafeMath {

    


    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        return a / b;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

































contract OraclizeAddrResolverI {
    function getAddress() returns (address _addr);
}





























library Buffer {
    struct buffer {
        bytes buf;
        uint capacity;
    }

    function init(buffer memory buf, uint capacity) internal constant {
        if (capacity % 32 != 0) capacity += 32 - (capacity % 32);
        
        buf.capacity = capacity;
        assembly {
            let ptr := mload(0x40)
            mstore(buf, ptr)
            mstore(0x40, add(ptr, capacity))
        }
    }

    function resize(buffer memory buf, uint capacity) private constant {
        bytes memory oldbuf = buf.buf;
        init(buf, capacity);
        append(buf, oldbuf);
    }

    function max(uint a, uint b) private constant returns (uint) {
        if (a > b) {
            return a;
        }
        return b;
    }

    






    function append(buffer memory buf, bytes data) internal constant returns (buffer memory) {
        if (data.length + buf.buf.length > buf.capacity) {
            resize(buf, max(buf.capacity, data.length) * 2);
        }

        uint dest;
        uint src;
        uint len = data.length;
        assembly {
        
            let bufptr := mload(buf)
        
            let buflen := mload(bufptr)
        
            dest := add(add(bufptr, buflen), 32)
        
            mstore(bufptr, add(buflen, mload(data)))
            src := add(data, 32)
        }

        
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }

        return buf;
    }

    






    function append(buffer memory buf, uint8 data) internal constant {
        if (buf.buf.length + 1 > buf.capacity) {
            resize(buf, buf.capacity * 2);
        }

        assembly {
        
            let bufptr := mload(buf)
        
            let buflen := mload(bufptr)
        
            let dest := add(add(bufptr, buflen), 32)
            mstore8(dest, data)
        
            mstore(bufptr, add(buflen, 1))
        }
    }

    






    function appendInt(buffer memory buf, uint data, uint len) internal constant returns (buffer memory) {
        if (len + buf.buf.length > buf.capacity) {
            resize(buf, max(buf.capacity, len) * 2);
        }

        uint mask = 256 ** len - 1;
        assembly {
        
            let bufptr := mload(buf)
        
            let buflen := mload(bufptr)
        
            let dest := add(add(bufptr, buflen), len)
            mstore(dest, or(and(mload(dest), not(mask)), data))
        
            mstore(bufptr, add(buflen, len))
        }
        return buf;
    }
}

library CBOR {
    using Buffer for Buffer.buffer;

    uint8 private constant MAJOR_TYPE_INT = 0;
    uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;
    uint8 private constant MAJOR_TYPE_BYTES = 2;
    uint8 private constant MAJOR_TYPE_STRING = 3;
    uint8 private constant MAJOR_TYPE_ARRAY = 4;
    uint8 private constant MAJOR_TYPE_MAP = 5;
    uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;

    function shl8(uint8 x, uint8 y) private constant returns (uint8) {
        return x * (2 ** y);
    }

    function encodeType(Buffer.buffer memory buf, uint8 major, uint value) private constant {
        if (value <= 23) {
            buf.append(uint8(shl8(major, 5) | value));
        } else if (value <= 0xFF) {
            buf.append(uint8(shl8(major, 5) | 24));
            buf.appendInt(value, 1);
        } else if (value <= 0xFFFF) {
            buf.append(uint8(shl8(major, 5) | 25));
            buf.appendInt(value, 2);
        } else if (value <= 0xFFFFFFFF) {
            buf.append(uint8(shl8(major, 5) | 26));
            buf.appendInt(value, 4);
        } else if (value <= 0xFFFFFFFFFFFFFFFF) {
            buf.append(uint8(shl8(major, 5) | 27));
            buf.appendInt(value, 8);
        }
    }

    function encodeIndefiniteLengthType(Buffer.buffer memory buf, uint8 major) private constant {
        buf.append(uint8(shl8(major, 5) | 31));
    }

    function encodeUInt(Buffer.buffer memory buf, uint value) internal constant {
        encodeType(buf, MAJOR_TYPE_INT, value);
    }

    function encodeInt(Buffer.buffer memory buf, int value) internal constant {
        if (value >= 0) {
            encodeType(buf, MAJOR_TYPE_INT, uint(value));
        } else {
            encodeType(buf, MAJOR_TYPE_NEGATIVE_INT, uint(- 1 - value));
        }
    }

    function encodeBytes(Buffer.buffer memory buf, bytes value) internal constant {
        encodeType(buf, MAJOR_TYPE_BYTES, value.length);
        buf.append(value);
    }

    function encodeString(Buffer.buffer memory buf, string value) internal constant {
        encodeType(buf, MAJOR_TYPE_STRING, bytes(value).length);
        buf.append(bytes(value));
    }

    function startArray(Buffer.buffer memory buf) internal constant {
        encodeIndefiniteLengthType(buf, MAJOR_TYPE_ARRAY);
    }

    function startMap(Buffer.buffer memory buf) internal constant {
        encodeIndefiniteLengthType(buf, MAJOR_TYPE_MAP);
    }

    function endSequence(Buffer.buffer memory buf) internal constant {
        encodeIndefiniteLengthType(buf, MAJOR_TYPE_CONTENT_FREE);
    }
}




