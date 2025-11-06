pragma solidity ^0.4.24;









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









contract Balance is Callable {
  using SafeMath for uint256;

  mapping (address => uint256) public balanceOf;

  uint256 public totalSupply;

  function addBalance(address _addr, uint256 _value) onlyCaller public {
    balanceOf[_addr] = balanceOf[_addr].add(_value);
  }

  function subBalance(address _addr, uint256 _value) onlyCaller public {
    balanceOf[_addr] = balanceOf[_addr].sub(_value);
  }

  function setBalance(address _addr, uint256 _value) onlyCaller public {
    balanceOf[_addr] = _value;
  }

  function addTotalSupply(uint256 _value) onlyCaller public {
    totalSupply = totalSupply.add(_value);
  }

  function subTotalSupply(uint256 _value) onlyCaller public {
    totalSupply = totalSupply.sub(_value);
  }
}







