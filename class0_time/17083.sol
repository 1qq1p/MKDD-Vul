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












contract Withdrawable is Ownable {
  address public withdrawer;

  


  modifier onlyWithdrawer() {
    require(msg.sender == withdrawer);
    _;
  }

  function setWithdrawer(address _newWithdrawer) external onlyOwner {
    withdrawer = _newWithdrawer;
  }

  



  function withdraw(uint256 _amount) external onlyWithdrawer returns(bool) {
    require(_amount <= address(this).balance);
    withdrawer.transfer(_amount);
    return true;
  }
}
