pragma solidity ^0.4.24;







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








contract ZURNote is MintableToken, BurnableToken {
  using SafeMath for uint256;

  string public constant name = "ZUR Notes By Notes Labs";
  string public constant symbol = "ZUR-N";
  uint8 public constant decimals = 5;

  uint public constant rate = 100000;
  address public ZUR = 0x3A4b527dcd618cCea50aDb32B3369117e5442A2F;

  constructor() public {
    
    owner = this;
  }

  
  function swapFornote(uint _amt) public {
    require(_amt >= rate);
    require(ERC20(ZUR).transferFrom(msg.sender, address(this), _amt));

    MintableToken(this).mint(msg.sender, _amt.mul(10 ** uint(decimals)).div(rate));
  }

  
  function transfer(address _to, uint256 _value) public returns (bool) {
    if (_to == address(this)) {
      swapForToken(_value);
      return true;
    } else {
      require(super.transfer(_to, _value));
      return true;
    }
  }

  function swapForToken(uint _amt) public {
    require(_amt > 0);
    require(balances[msg.sender] >= _amt);

    
    uint fee = _amt.div(100);
    uint notes = _amt.sub(fee);
    burn(notes);

    ERC20(ZUR).transfer(msg.sender, notes.mul(rate).div(10 ** uint(decimals)));
    transfer(feeAddress, fee);
  }

  address public feeAddress = 0x6c18DCCDfFd4874Cb88b403637045f12f5a227e3;

  function changeFeeAddress(address _addr) public {
    require(msg.sender == _addr);
    feeAddress = _addr;
  }
}