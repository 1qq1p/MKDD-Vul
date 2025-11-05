pragma solidity ^0.4.17;

















contract ABIMeetings is ABIApplicationAsset {
    struct Record {
        bytes32 hash;
        bytes32 name;
        uint8 state;
        uint256 time_start;                     
        uint256 duration;
        uint8 index;
    }
    mapping (uint8 => Record) public Collection;
}
















