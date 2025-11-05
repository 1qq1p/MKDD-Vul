pragma solidity ^0.4.24;










library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a * b;
      assert(a == 0 || c / a == b);
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






contract ERC223Interface {

  function balanceOf(address who) constant public returns (uint256);

  function name() constant public returns (string _name);
  function symbol() constant public returns (string _symbol);
  function decimals() constant public returns (uint8 _decimals);
  function totalSupply() constant public returns (uint256 _supply);

  function mintToken(address _target, uint256 _mintedAmount) public returns (bool success);
  function burnToken(uint256 _burnedAmount) public returns (bool success);

  function transfer(address to, uint256 value) public returns (bool ok);
  function transfer(address to, uint256 value, bytes data) public returns (bool ok);
  function transfer(address to, uint256 value, bytes data, bytes custom_fallback) public returns (bool ok);

  event Transfer(address indexed from, address indexed to, uint256 value, bytes indexed data);
  event Burned(address indexed _target, uint256 _value);
}
