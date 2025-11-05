pragma solidity ^0.4.13;







contract GenesisToken is StandardToken, Ownable {
  using SafeMath for uint256;

  
  string public constant name = 'Genesis';
  string public constant symbol = 'GNS';
  uint256 public constant decimals = 18;
  string public version = '0.0.1';

  
  event EarnedGNS(address indexed contributor, uint256 amount);
  event TransferredGNS(address indexed from, address indexed to, uint256 value);

  
  function GenesisToken(
    address _owner,
    uint256 initialBalance)
  {
    owner = _owner;
    totalSupply = initialBalance;
    balances[_owner] = initialBalance;
    EarnedGNS(_owner, initialBalance);
  }

  





  function giveTokens(address _to, uint256 _amount) onlyOwner returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    EarnedGNS(_to, _amount);
    return true;
  }
}




