pragma solidity 0.5.5;





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
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}

contract ERC20 {
  function totalSupply()public view returns (uint256 total_Supply);
  function balanceOf(address who)public view returns (uint256);
  function allowance(address owner, address spender)public view returns (uint256);
  function transferFrom(address from, address to, uint256 value)public returns (bool ok);
  function approve(address spender, uint256 value)public returns (bool ok);
  function transfer(address to, uint256 value)public returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
