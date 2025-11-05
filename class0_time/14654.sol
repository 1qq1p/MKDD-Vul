pragma solidity 0.4.24;


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
}

library Percent {
  using SafeMath for uint256;
  


  function perc
  (
    uint256 initialValue,
    uint256 percent
  ) 
    internal 
    pure 
    returns(uint256 result) 
  { 
    return initialValue.div(100).mul(percent);
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












contract Whitelist is Ownable, RBAC {
  string public constant ROLE_WHITELISTED = "whitelist";

  



  modifier onlyIfWhitelisted(address _operator) {
    checkRole(_operator, ROLE_WHITELISTED);
    _;
  }

  




  function addAddressToWhitelist(address _operator)
    onlyOwner
    public
  {
    addRole(_operator, ROLE_WHITELISTED);
  }

  


  function whitelist(address _operator)
    public
    view
    returns (bool)
  {
    return hasRole(_operator, ROLE_WHITELISTED);
  }

  





  function addAddressesToWhitelist(address[] _operators)
    onlyOwner
    public
  {
    for (uint256 i = 0; i < _operators.length; i++) {
      addAddressToWhitelist(_operators[i]);
    }
  }

  





  function removeAddressFromWhitelist(address _operator)
    onlyOwner
    public
  {
    removeRole(_operator, ROLE_WHITELISTED);
  }

  





  function removeAddressesFromWhitelist(address[] _operators)
    onlyOwner
    public
  {
    for (uint256 i = 0; i < _operators.length; i++) {
      removeAddressFromWhitelist(_operators[i]);
    }
  }

}

