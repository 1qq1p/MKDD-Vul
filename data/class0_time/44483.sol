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








contract GambioToken is CappedToken {


  using SafeMath for uint256;

  string public name = "GMB";
  string public symbol = "GMB";
  uint8 public decimals = 18;

  event Burn(address indexed burner, uint256 value);
  event BurnTransferred(address indexed previousBurner, address indexed newBurner);

  address burnerRole;

  modifier onlyBurner() {
    require(msg.sender == burnerRole);
    _;
  }

  constructor(address _burner, uint256 _cap) public CappedToken(_cap) {
    burnerRole = _burner;
  }

  function transferBurnRole(address newBurner) public onlyBurner {
    require(newBurner != address(0));
    emit BurnTransferred(burnerRole, newBurner);
    burnerRole = newBurner;
  }

  function burn(uint256 _value) public onlyBurner {
    require(_value <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(msg.sender, _value);
    emit Transfer(msg.sender, address(0), _value);
  }
}


