pragma solidity ^0.4.24;







library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }

  


  function divRemain(uint256 numerator, uint256 denominator) internal pure returns (uint256 quotient, uint256 remainder) {
    quotient  = div(numerator, denominator);
    remainder = sub(numerator, mul(denominator, quotient));
  }
}








library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  


  function add(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = true;
  }

  


  function remove(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = false;
  }

  



  function check(Role storage role, address addr)
    view
    internal
  {
    require(has(role, addr));
  }

  



  function has(Role storage role, address addr)
    view
    internal
    returns (bool)
  {
    return role.bearer[addr];
  }
}













contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address indexed operator, string role);
  event RoleRemoved(address indexed operator, string role);
  event RoleRemovedAll(string role);

  





  function checkRole(address _operator, string _role)
    view
    public
  {
    roles[_role].check(_operator);
  }

  





  function hasRole(address _operator, string _role)
    view
    public
    returns (bool)
  {
    return roles[_role].has(_operator);
  }

  




  function addRole(address _operator, string _role)
    internal
  {
    roles[_role].add(_operator);
    emit RoleAdded(_operator, _role);
  }

  




  function removeRole(address _operator, string _role)
    internal
  {
    roles[_role].remove(_operator);
    emit RoleRemoved(_operator, _role);
  }

  



  function removeRoleAll(string _role)
    internal
  {
    delete roles[_role];
    emit RoleRemovedAll(_role);
  }

  




  modifier onlyRole(string _role)
  {
    checkRole(msg.sender, _role);
    _;
  }

  







  
  
  
  
  
  
  
  

  

  
  
}






