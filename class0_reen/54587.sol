pragma solidity 0.4.24;







contract Lockable {
    bool public tokenTransfer;
    address public owner;

    


    mapping(address => bool) public unlockAddress;

    


    mapping(address => bool) public lockAddress;

    event Locked(address lockAddress, bool status);
    event Unlocked(address unlockedAddress, bool status);

    


    modifier isTokenTransfer {
        if(!tokenTransfer) {
            require(unlockAddress[msg.sender]);
        }
        _;
    }

    


    modifier checkLock {
        require(!lockAddress[msg.sender]);
        _;
    }

    modifier isOwner
    {
        require(owner == msg.sender);
        _;
    }

    constructor()
    public
    {
        tokenTransfer = false;
        owner = msg.sender;
    }

    


    function setLockAddress(address target, bool status)
    external
    isOwner
    {
        require(owner != target);
        lockAddress[target] = status;
        emit Locked(target, status);
    }

    


    function setUnlockAddress(address target, bool status)
    external
    isOwner
    {
        unlockAddress[target] = status;
        emit Unlocked(target, status);
    }
}







