pragma solidity ^0.4.17;

library SafeCalc {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
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
contract ERC20Standard {


    
    function totalSupply() public constant returns (uint256) ;

    


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    


    function transfer(address _to, uint256 _value) public returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);


    function approve(address _spender, uint256 _value) public returns (bool);

    function balanceOf(address _owner) public constant returns (uint256);

    function allowance(address _owner, address _spender) public constant returns (uint256);
}
