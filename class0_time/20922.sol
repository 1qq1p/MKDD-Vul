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







contract CappedDividendToken is MintableDividendToken {
    uint256 public cap;

    function CappedDividendToken(uint256 _cap) public {
        require(_cap > 0);
        cap = _cap;
    }

    





    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        require(totalSupply_.add(_amount) <= cap);
        
        return super.mint(_to, _amount);
    }
}

