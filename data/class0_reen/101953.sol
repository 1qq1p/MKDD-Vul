pragma solidity ^0.4.16;















contract Tincoin is BurnableToken {
    
  string public constant name = "Tincoin";
   
  string public constant symbol = "TIN";
    
  uint8 public constant decimals = 18;

  uint256 public INITIAL_SUPPLY = 100000000 * 1 ether;

  function Tincoin  () {
    totalSupply = INITIAL_SUPPLY;
    balances[0x2ff19Ce720e19d0F010f953CE3FAFd3E3A0A55a4] = INITIAL_SUPPLY;
  }
    
}
