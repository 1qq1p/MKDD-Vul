pragma solidity ^0.4.24;




contract Mortal is DSAuth {
    function kill() public auth {
        selfdestruct(owner);
    }
}
