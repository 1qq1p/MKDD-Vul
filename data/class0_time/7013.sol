pragma solidity ^0.4.24;





interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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








contract LYZEToken is ERC20, Ownable {

  uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** 18);

  


  constructor() public ERC20("LYZE Token", "LZE", 18) Ownable() {
    _mint(msg.sender, INITIAL_SUPPLY);
  }

  
  bool private _mintingFinished = false;

  event MintingFinished();

  modifier canMint() {
    require(!_mintingFinished);
    _;
  }

  





  function mint(address to, uint256 value) public onlyAdmin canMint returns (bool) {
    _mint(to, value);
    return true;
  }

  function finishMinting() public onlyAdmin canMint returns (bool) {
    _mintingFinished = true;
    emit MintingFinished();
    return true;
  }

  



  function burn(uint256 value) public onlyAdmin {
    _burn(msg.sender, value);
  }

  




  function burnFrom(address from, uint256 value) public onlyAdmin {
    _burnFrom(from, value);
  }

  




  function multiTransfer(address[] tos, uint256[] values) public returns (bool) {
    require(tos.length>0 && tos.length==values.length);
    for (uint256 i = 0; i < tos.length; ++i) {
      _transfer(msg.sender, tos[i], values[i]);
    }
    return true;
  }

}