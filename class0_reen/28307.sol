contract mortal {
    
    address owner;

    
    function mortal() { owner = msg.sender; }

    
    function kill() { if (msg.sender == owner) selfdestruct(owner); }
}































pragma solidity ^0.4.0;

contract OraclizeAddrResolverI {
    function getAddress() returns (address _addr);
}