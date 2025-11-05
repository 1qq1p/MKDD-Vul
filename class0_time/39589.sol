pragma solidity 0.4.15;



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




contract DepositRegistry {
    
    function register(address key, uint256 amount, address depositOwner);

    
    function unregister(address key);

    function transfer(address key, address newOwner, address sender);

    function spend(address key, uint256 amount);

    function refill(address key, uint256 amount);

    
    function isRegistered(address key) constant returns(bool);

    function getDepositOwner(address key) constant returns(address);

    function getDeposit(address key) constant returns(uint256 amount);

    function getDepositRecord(address key) constant returns(address owner, uint time, uint256 amount, address depositOwner);

    function hasEnough(address key, uint256 amount) constant returns(bool);

    function kill();
}
