pragma solidity ^0.4.24;








contract AccountLockableToken is Ownable {
    mapping(address => bool) public lockStates;

    event LockAccount(address indexed lockAccount);
    event UnlockAccount(address indexed unlockAccount);

    


    modifier whenNotLocked() {
        require(!lockStates[msg.sender]);
        _;
    }

    



    function lockAccount(address _target) public
        onlyOwner
        returns (bool)
    {
        require(_target != owner);
        require(!lockStates[_target]);

        lockStates[_target] = true;

        emit LockAccount(_target);

        return true;
    }

    



    function unlockAccount(address _target) public
        onlyOwner
        returns (bool)
    {
        require(_target != owner);
        require(lockStates[_target]);

        lockStates[_target] = false;

        emit UnlockAccount(_target);

        return true;
    }
}






