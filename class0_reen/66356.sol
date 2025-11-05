pragma solidity ^0.4.13;

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

contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 private _openingTime;
  uint256 private _closingTime;

  


  modifier onlyWhileOpen {
    require(isOpen());
    _;
  }

  




  constructor(uint256 openingTime, uint256 closingTime) public {
    
    require(openingTime >= block.timestamp);
    require(closingTime >= openingTime);

    _openingTime = openingTime;
    _closingTime = closingTime;
  }

  


  function openingTime() public view returns(uint256) {
    return _openingTime;
  }

  


  function closingTime() public view returns(uint256) {
    return _closingTime;
  }

  


  function isOpen() public view returns (bool) {
    
    return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
  }

  



  function hasClosed() public view returns (bool) {
    
    return block.timestamp > _closingTime;
  }

  




  function _preValidatePurchase(
    address beneficiary,
    uint256 weiAmount
  )
    internal
    onlyWhileOpen
  {
    super._preValidatePurchase(beneficiary, weiAmount);
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
