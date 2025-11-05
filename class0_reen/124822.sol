pragma solidity ^0.4.20;

contract Pointer {
    uint256 public pointer;

    function bumpPointer() internal returns (uint256 p) {
        return pointer++;
    }
}
