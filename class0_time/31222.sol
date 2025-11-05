pragma solidity ^0.4.18;



library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    
    uint c = a / b;
    
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal pure  returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

  
}
contract ERC20Interface {
    function totalSupply() public view returns (uint supply);
    function balanceOf( address owner ) public view returns (uint value);
    function allowance( address owner, address spender ) public view returns (uint _allowance);

    function transfer( address to, uint value) public returns (bool success);
    function transferFrom( address from, address to, uint value) public returns (bool success);
    function approve( address spender, uint value ) public returns (bool success);

    event Transfer( address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);
}
