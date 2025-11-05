pragma solidity ^0.4.21;














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









contract ERC20Template is DetailedERC20, PausableToken, BurnableToken, CappedToken {
  


   string public _name = 'ZPoker';
   string public _symbol = 'POK';
   uint8 _decimals = 8;
   uint256 initialSupply = 3000000000*(10**8);
   address initHold = 0x6295a2c47dc0edc26694bc2f4c509e35be180f5d;
  function ERC20Template() public
    DetailedERC20(_name, _symbol, _decimals)
    CappedToken( initialSupply )
   {
    mint(initHold, initialSupply);
    transferOwnership(initHold);
  }
}