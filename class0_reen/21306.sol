pragma solidity ^0.4.23;






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







contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  



  constructor() public {
    owner = msg.sender;
  }

  


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  



  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  


  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
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












