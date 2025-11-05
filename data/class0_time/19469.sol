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






contract NoteChainToken is StandardToken {

  string public constant name = "NoteChain";
  string public constant symbol = "NOTE";
  uint256 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 20000000000 * 10**decimals;

  


  constructor() public {
    totalSupply = INITIAL_SUPPLY;
    balances[address(0x750Da02fb96538AbAf5aDd7E09eAC25f1553109D)] = (INITIAL_SUPPLY.mul(20).div(100));
    balances[address(0xb85e5Eb2C4F43fE44c1dF949c1c49F1638cb772B)] = (INITIAL_SUPPLY.mul(20).div(100));
    balances[address(0xBd058b319A1355A271B732044f37BBF2Be07A0B1)] = (INITIAL_SUPPLY.mul(25).div(100));
    balances[address(0x53da2841810e6886254B514d338146d209B164a2)] = (INITIAL_SUPPLY.mul(35).div(100));
  }
  


}