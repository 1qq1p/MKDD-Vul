pragma solidity ^0.4.24;

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

contract ERC20 is IERC20, Ownable {
    
  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowed;
  mapping (address => bool) public frozenAccount;
  event frozenFunds(address account, bool freeze);
  uint256 private _totalSupply;
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }
  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender];
  }
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }
  
  function transfer(address to, uint256 value, bytes data) external returns (bool) {
    require(transfer(to, value));

   uint codeLength;

   assembly {
    
    codeLength := extcodesize(to)
  }

  if (codeLength > 0) {
    ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
    receiver.tokenFallback(msg.sender, value, data);
    }
  return true;
  
  }
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }
  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    require(value <= _allowed[from][msg.sender]);
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));
    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
   require(!frozenAccount[msg.sender]);
  }
  function _issue(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);
    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
    _burn(account, value);
  }
}
