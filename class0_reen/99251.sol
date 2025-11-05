pragma solidity ^0.4.24;








library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  


  function add(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = true;
  }

  


  function remove(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = false;
  }

  



  function check(Role storage _role, address _addr)
    internal
    view
  {
    require(has(_role, _addr));
  }

  



  function has(Role storage _role, address _addr)
    internal
    view
    returns (bool)
  {
    return _role.bearer[_addr];
  }
}








contract Operable is Ownable, RBAC {
    
    string public constant ROLE_OPERATOR = "operator";

    


    modifier hasOperatePermission() {
        require(hasRole(msg.sender, ROLE_OPERATOR));
        _;
    }

    


    modifier hasOwnerOrOperatePermission() {
        require(msg.sender == owner || hasRole(msg.sender, ROLE_OPERATOR));
        _;
    }

    


    function operator(address _operator) public view returns (bool) {
        return hasRole(_operator, ROLE_OPERATOR);
    }

    



    function addOperator(address _operator) onlyOwner public {
        addRole(_operator, ROLE_OPERATOR);
    }

    



    function removeOperator(address _operator) onlyOwner public {
        removeRole(_operator, ROLE_OPERATOR);
    }
}








