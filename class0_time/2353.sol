pragma solidity ^0.4.19;





library SafeMath {

  


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    
    
    
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  


  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
    return _a / _b;
  }

  


  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  


  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

contract SyscoinDepositsManager {

    using SafeMath for uint;

    mapping(address => uint) public deposits;

    event DepositMade(address who, uint amount);
    event DepositWithdrawn(address who, uint amount);

    
    function() public payable {
        makeDeposit();
    }

    
    
    
    function getDeposit(address who) constant public returns (uint) {
        return deposits[who];
    }

    
    
    function makeDeposit() public payable returns (uint) {
        increaseDeposit(msg.sender, msg.value);
        return deposits[msg.sender];
    }

    
    
    function increaseDeposit(address who, uint amount) internal {
        deposits[who] = deposits[who].add(amount);
        require(deposits[who] <= address(this).balance);

        emit DepositMade(who, amount);
    }

    
    
    
    function withdrawDeposit(uint amount) public returns (uint) {
        require(deposits[msg.sender] >= amount);

        deposits[msg.sender] = deposits[msg.sender].sub(amount);
        msg.sender.transfer(amount);

        emit DepositWithdrawn(msg.sender, amount);
        return deposits[msg.sender];
    }
}

