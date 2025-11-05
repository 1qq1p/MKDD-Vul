pragma solidity 0.4.24;





library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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

contract ERC20 {
  function totalSupply()public view returns (uint total_Supply);
  function balanceOf(address _owner)public view returns (uint256 balance);
  function allowance(address _owner, address _spender)public view returns (uint remaining);
  function transferFrom(address _from, address _to, uint _amount)public returns (bool ok);
  function approve(address _spender, uint _amount)public returns (bool ok);
  function transfer(address _to, uint _amount)public returns (bool ok);
  event Transfer(address indexed _from, address indexed _to, uint _amount);
  event Approval(address indexed _owner, address indexed _spender, uint _amount);
}

