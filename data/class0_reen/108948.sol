pragma solidity 0.5.8;









contract Graceful {
    event Error(bytes32 message);

    
    function _softRequire(bool _condition, bytes32 _message) internal {
        if (_condition) {
            return;
        }
        emit Error(_message);
        
        assembly {
            mstore(0, 0)
            return(0, 32)
        }
    }

    
    function _hardRequire(bool _condition, bytes32 _message) internal pure {
        if (_condition) {
            return;
        }
        
        assembly {
            mstore(0, _message)
            revert(0, 32)
        }
    }

    function _not(bool _condition) internal pure returns(bool) {
        return !_condition;
    }
}




















