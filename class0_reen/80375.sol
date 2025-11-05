pragma solidity ^0.4.17;





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







contract BasicToken is ERC20Basic {
    
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  bool public mintingFinished = false;

  mapping(address => uint256) releaseTime;
  
  modifier timeAllowed() {
    require(mintingFinished);
    require(now > releaseTime[msg.sender]); 
    _;
  }

  




  function transfer(address _to, uint256 _value) public timeAllowed returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  




  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

  
  function releaseAt(address _owner) public constant returns (uint256 date) {
    return releaseTime[_owner];
  }
  
  function changeReleaseAccount(address _owner, address _newowner) public returns (bool) {
    require(releaseTime[_owner] != 0 );
    require(releaseTime[_newowner] == 0 );
    balances[_newowner] = balances[_owner];
    releaseTime[_newowner] = releaseTime[_owner];
    balances[_owner] = 0;
    releaseTime[_owner] = 0;
    return true;
  }

}







