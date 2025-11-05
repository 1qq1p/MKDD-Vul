pragma solidity 0.5.6;













contract ERC20Detailed {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor (string memory name, string memory symbol, uint8 decimals) public {
      _name = name;
      _symbol = symbol;
      _decimals = decimals;
  }

  


  function name() public view returns (string memory) {
      return _name;
  }

  


  function symbol() public view returns (string memory) {
      return _symbol;
  }

  


  function decimals() public view returns (uint8) {
      return _decimals;
  }
}





library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); 
    uint256 c = a / b;
    

    return c;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  



  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}







