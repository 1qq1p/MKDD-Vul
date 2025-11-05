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







contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    
    uint constant public SUPPLY_HARD_CAP = 2700 * 1e6 * 1e18;
    bool public mintingFinished = false;

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    modifier hasMintPermission() {
        require(msg.sender == owner);
        _;
    }

    





    function mint(
        address _to,
        uint256 _amount
    )
        public
        hasMintPermission
        canMint
        returns (bool)
    {
        require( totalSupply_.add(_amount) <= SUPPLY_HARD_CAP );
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    



    function finishMinting() public onlyOwner canMint returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }
}

