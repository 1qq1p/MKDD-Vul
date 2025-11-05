


pragma solidity ^0.4.17;

contract Lockable is Ownable {
    bool public Locked;
    
    modifier isUnlocked {
        require(!Locked);
        _;
    }
    function Lockable() { Locked = false; }
    function lock() public onlyOwner { Locked = true; }
    function unlock() public onlyOwner { Locked = false; }
}
