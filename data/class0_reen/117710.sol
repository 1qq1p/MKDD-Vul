pragma solidity ^0.4.23;
















library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}







contract BasicToken is ERC20Basic, Ownable {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  
  
  mapping(address => bool) public allowedAddresses;
  mapping(address => bool) public lockedAddresses;
  bool public locked = true;

  function allowAddress(address _addr, bool _allowed) public onlyOwner {
    require(_addr != owner);
    allowedAddresses[_addr] = _allowed;
  }

  function lockAddress(address _addr, bool _locked) public onlyOwner {
    require(_addr != owner);
    lockedAddresses[_addr] = _locked;
  }

  function setLocked(bool _locked) public onlyOwner {
    locked = _locked;
  }

  function canTransfer(address _addr) public constant returns (bool) {
    if(locked){
      if(!allowedAddresses[_addr]&&_addr!=owner) return false;
    }else if(lockedAddresses[_addr]) return false;

    return true;
  }




  




  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(canTransfer(msg.sender));
    

    
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  




  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
}




