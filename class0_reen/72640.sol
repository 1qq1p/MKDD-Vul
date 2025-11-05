pragma solidity ^0.4.20;

library safeMath
{
  function add(uint256 a, uint256 b) internal pure returns (uint256)
  {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256)
  {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }
  function mul(uint256 a, uint256 b) internal pure returns (uint256)
  {
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256)
  {
    require(b > 0);
    uint256 c = a / b;
    return c;
  }
  function mod(uint256 a, uint256 b) internal pure returns (uint256)
  {
    require(b != 0);
    return a % b;
  }
}

contract Get is Variable, Modifiers
{
  using safeMath for uint256;

  function get_tokenTime() public view returns(uint256 start, uint256 stop)
  {
    return (ico_open_time,ico_closed_time);
  }
  function get_transferLock() public view returns(bool)
  {
    return transferLock;
  }
  function get_depositLock() public view returns(bool)
  {
    return depositLock;
  }
  function get_tokenReward() public view returns(uint256)
  {
    return tokenReward;
  }
}
