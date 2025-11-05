pragma solidity ^0.4.18;





library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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







contract PendingManagerEmitter {

    event PolicyRuleAdded(bytes4 sig, address contractAddress, bytes32 key, bytes32 groupName, uint acceptLimit, uint declinesLimit);
    event PolicyRuleRemoved(bytes4 sig, address contractAddress, bytes32 key, bytes32 groupName);

    event ProtectionTxAdded(bytes32 key, bytes32 sig, uint blockNumber);
    event ProtectionTxAccepted(bytes32 key, address indexed sender, bytes32 groupNameVoted);
    event ProtectionTxDone(bytes32 key);
    event ProtectionTxDeclined(bytes32 key, address indexed sender, bytes32 groupNameVoted);
    event ProtectionTxCancelled(bytes32 key);
    event ProtectionTxVoteRevoked(bytes32 key, address indexed sender, bytes32 groupNameVoted);
    event TxDeleted(bytes32 key);

    event Error(uint errorCode);

    function _emitError(uint _errorCode) internal returns (uint) {
        Error(_errorCode);
        return _errorCode;
    }
}
