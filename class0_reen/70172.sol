pragma solidity ^0.4.24;






contract LockableToken is StandardToken, MultiOwnable {
    bool public locked = true;
    uint256 public constant LOCK_MAX = uint256(-1);

    


    mapping(address => bool) public unlockAddrs;

    




    mapping(address => uint256) public lockValues;

    event Locked(bool locked, string note);
    event LockedTo(address indexed addr, bool locked, string note);
    event SetLockValue(address indexed addr, uint256 value, string note);

    constructor() public {
        unlockTo(msg.sender,  "");
    }

    modifier checkUnlock (address addr, uint256 value) {
        require(!locked || unlockAddrs[addr], "The account is currently locked.");
        require(balances[addr].sub(value) >= lockValues[addr], "Transferable limit exceeded. Check the status of the lock value.");
        _;
    }

    function lock(string note) onlyOwner public {
        locked = true;
        emit Locked(locked, note);
    }

    function unlock(string note) onlyOwner public {
        locked = false;
        emit Locked(locked, note);
    }

    function lockTo(address addr, string note) onlyOwner public {
        setLockValue(addr, LOCK_MAX, note);
        unlockAddrs[addr] = false;

        emit LockedTo(addr, true, note);
    }

    function unlockTo(address addr, string note) onlyOwner public {
        if (lockValues[addr] == LOCK_MAX)
            setLockValue(addr, 0, note);
        unlockAddrs[addr] = true;

        emit LockedTo(addr, false, note);
    }

    function setLockValue(address addr, uint256 value, string note) onlyOwner public {
        lockValues[addr] = value;
        emit SetLockValue(addr, value, note);
    }

    


    function getMyUnlockValue() public view returns (uint256) {
        address addr = msg.sender;
        if ((!locked || unlockAddrs[addr]) && balances[addr] > lockValues[addr])
            return balances[addr].sub(lockValues[addr]);
        else
            return 0;
    }

    function transfer(address to, uint256 value) checkUnlock(msg.sender, value) public returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) checkUnlock(from, value) public returns (bool) {
        return super.transferFrom(from, to, value);
    }
}




