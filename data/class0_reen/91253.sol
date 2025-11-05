pragma solidity ^0.4.24;





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






contract MintableToken is StandardToken, TokenControl {
    event Mint(address indexed to, uint256 amount);
    

     



    function mint(uint256 _value) onlyCOO whenNotPaused  public {
        _mint(_value);
    }

    function _mint( uint256 _value) internal {
        
        balances[cfoAddress] = balances[cfoAddress].add(_value);
        totalSupply_ = totalSupply_.add(_value);
        emit Mint(cfoAddress, _value);
        emit Transfer(address(0), cfoAddress, _value);
    }

}






