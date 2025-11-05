pragma solidity ^0.4.21;










contract LockRequestable {

    
    
    uint256 public lockRequestCount;

    
    function LockRequestable() public {
        lockRequestCount = 0;
    }

    
    











    function generateLockId() internal returns (bytes32 lockId) {
        return keccak256(block.blockhash(block.number - 1), address(this), ++lockRequestCount);
    }
}











