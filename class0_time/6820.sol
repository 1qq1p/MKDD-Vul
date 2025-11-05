pragma solidity ^0.4.18;

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  mapping(address => bool) frozenAddress;

  function checkFrozen(address checkAddress) internal view returns (bool) {
    return frozenAddress[checkAddress];
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    require(!checkFrozen(msg.sender));

    
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
}

