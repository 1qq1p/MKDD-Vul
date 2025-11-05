pragma solidity ^0.4.17;

contract Owned {
    address public Owner;
    function Owned() { Owner = msg.sender; }
    modifier onlyOwner { if ( msg.sender == Owner ) _; }
}
