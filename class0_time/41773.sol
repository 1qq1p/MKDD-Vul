pragma solidity ^0.4.25; 










library SafeMath {

  


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    
    
    
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  


  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
    return _a / _b;
  }

  


  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  


  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}






contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address indexed operator, string role);
  event RoleRemoved(address indexed operator, string role);

  





  function checkRole(address _operator, string _role)
    public
    view
  {
    roles[_role].check(_operator);
  }

  





  function hasRole(address _operator, string _role)
    public
    view
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

  




  modifier onlyRole(string _role)
  {
    checkRole(msg.sender, _role);
    _;
  }

  







  
  
  
  
  
  
  
  

  

  
  
}





