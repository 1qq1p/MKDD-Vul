
     
     
     
     

pragma solidity ^0.4.18;

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

contract BurnableToken is StandardToken, Ownable {
    using SafeMath for uint256;

    
    event Burn(address indexed from, uint256 value);

    function burn(uint256 _value) public onlyOwner returns (bool success) {
        
        require(balances[msg.sender] >= _value);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender, _value);
        return true;
    }

}
