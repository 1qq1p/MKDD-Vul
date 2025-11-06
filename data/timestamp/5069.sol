pragma solidity 0.4.24;







library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  


  function add(Role storage role, address account) internal {
    require(account != address(0));
    role.bearer[account] = true;
  }

  


  function remove(Role storage role, address account) internal {
    require(account != address(0));
    role.bearer[account] = false;
  }

  



  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}



contract ReferrerRole is Ownable {
    using Roles for Roles.Role;

    event ReferrerAdded(address indexed account);
    event ReferrerRemoved(address indexed account);

    Roles.Role private referrers;

    constructor() public {
        referrers.add(msg.sender);
    }

    modifier onlyReferrer() {
        require(isReferrer(msg.sender));
        _;
    }
    
    function isReferrer(address account) public view returns (bool) {
        return referrers.has(account);
    }

    function addReferrer(address account) public onlyOwner() {
        referrers.add(account);
        emit ReferrerAdded(account);
    }

    function removeReferrer(address account) public onlyOwner() {
        referrers.remove(account);
        emit ReferrerRemoved(account);
    }

}


