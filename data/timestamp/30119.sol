pragma solidity ^0.4.20;

contract GenesisProtected {
    modifier addrNotNull(address _address) {
        require(_address != address(0));
        _;
    }
}















