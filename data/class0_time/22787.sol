pragma solidity ^0.4.25;

library SafeMath {
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    if (_a == 0) {
      return 0;
    }
    uint256 c = _a * _b;
    require(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0);
    uint256 c = _a / _b;
    return c;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;
    return c;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);
    return c;
  }
}

library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  function add(Role storage _role, address _account) internal {
    require(_account != address(0));
    _role.bearer[_account] = true;
  }

  function remove(Role storage _role, address _account) internal {
    require(_account != address(0));
    _role.bearer[_account] = false;
  }

  function has(Role storage _role, address _account) internal view returns (bool)
  {
    require(_account != address(0));
    return _role.bearer[_account];
  }
}

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address _who) external view returns (uint256);

  function allowance(address _owner, address _spender) external view returns (uint256);

  function transfer(address _to, uint256 _value) external returns (bool);

  function approve(address _spender, uint256 _value) external returns (bool);

  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BMToken is ERC20Pausable, ERC20Burnable {
  string public constant name = "Boombit Token";
  string public constant symbol = "BM";
  uint8 public constant decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 10000000000 * (10 ** uint256(decimals));

  constructor() public {
    _mint(msg.sender, INITIAL_SUPPLY);
  }
}