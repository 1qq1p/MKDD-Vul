pragma solidity ^0.4.22;

contract MintableToken is StandardToken {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  string public symbol;
  string public name;
  uint8 public decimals = 18;
  uint public _totalSupply;
  address public _owner;

  bool public mintingFinished = false;

constructor(string _symbol, string _name, address _owner) public {
    	symbol = _symbol;
    	name = _name;
    	decimals = 18;
    	totalSupply = _totalSupply;
    	balances[_owner] = _totalSupply;
    	emit Transfer(address(0), _owner, _totalSupply);
}


  modifier canMint() {
    require(!mintingFinished);
    _;
  }
  

  





  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  



  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}