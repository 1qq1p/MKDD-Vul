pragma solidity 0.4.20;

contract ITime is Controlled, ITyped {
    function getTimestamp() external view returns (uint256);
}
