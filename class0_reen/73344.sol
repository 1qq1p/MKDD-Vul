pragma solidity ^0.4.10;

contract IMigrationContract {
    function migrate(address addr, uint256 uip) returns (bool success);
}
