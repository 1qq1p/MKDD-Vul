pragma solidity ^0.4.24;






contract Freezable is Administratable {
    bool public frozenToken;
    mapping (address => bool) public frozenAccounts;
    event FrozenFunds(address indexed _target, bool _frozen);
    event FrozenToken(bool _frozen);
    modifier isNotFrozen( address _to ) {
        require(!frozenToken);
        require(!frozenAccounts[msg.sender] && !frozenAccounts[_to]);
        _;
    }
    modifier isNotFrozenFrom( address _from, address _to ) {
        require(!frozenToken);
        require(!frozenAccounts[msg.sender] && !frozenAccounts[_from] && !frozenAccounts[_to]);
        _;
    }
    function freezeAccount(address _target, bool _freeze) public onlySuperAdmins validateAddress(_target) {
        require(frozenAccounts[_target] != _freeze);
        frozenAccounts[_target] = _freeze;
        emit FrozenFunds(_target, _freeze);
    }
    function freezeToken(bool _freeze) public onlySuperAdmins {
        require(frozenToken != _freeze);
        frozenToken = _freeze;
        emit FrozenToken(frozenToken);
    }
}





library SafeMath {
  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }
  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); 
    uint256 c = a / b;
    
    return c;
  }
  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }
  


  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
  



  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}





interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender)
    external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value)
    external returns (bool);
  function transferFrom(address from, address to, uint256 value)
    external returns (bool);
  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}







