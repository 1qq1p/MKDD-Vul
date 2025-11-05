pragma solidity ^0.4.15;

contract Versionable {
    string public versionCode;

    function getVersionByte(uint index) constant returns (bytes1) { 
        return bytes(versionCode)[index];
    }

    function getVersionLength() constant returns (uint256) {
        return bytes(versionCode).length;
    }
}
