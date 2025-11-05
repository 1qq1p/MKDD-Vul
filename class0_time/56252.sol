pragma solidity ^0.5.2;





library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    


    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    


    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    



    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

contract Locked is Ownable {

    mapping (address => bool) public lockedList;

    event AddedLock(address user);
    event RemovedLock(address user);


    
    
    
    modifier isNotLocked(address _from, address _to) {

        if (_from != owner()) {  
            require(!lockedList[_from], "User is locked");
            require(!lockedList[_to], "User is locked");
        }
        _;
    }

    
    
    
    function isLocked(address _user) public view returns (bool) {
        return lockedList[_user];
    }
    
    
    
    function addLock (address _user) public onlyOwner {
        _addLock(_user);
    }

    
    
    function removeLock (address _user) public onlyOwner {
        _removeLock(_user);
    }


    
    
    function _addLock(address _user) internal {
        lockedList[_user] = true;
        emit AddedLock(_user);
    }

    
    
    function _removeLock (address _user) internal {
        lockedList[_user] = false;
        emit RemovedLock(_user);
    }

}




