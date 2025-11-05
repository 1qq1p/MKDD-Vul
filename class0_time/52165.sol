pragma solidity 0.5.8;

library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value, string reason);

  




  function burn(uint256 _value, string memory _reason) public {
    require(_value <= balances[msg.sender]);
	   
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalTokenSupply = totalTokenSupply.sub(_value);
    emit Burn(burner, _value, _reason);
  }
}
