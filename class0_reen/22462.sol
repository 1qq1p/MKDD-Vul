pragma solidity ^0.4.24;

contract Manageable is Transferable, Owned {
  event Deposit(
      address indexed _from,
      
      uint _value,
      string comment
  );

  event Withdraw(
      address indexed _to,
      uint _value,
      string comment
  );

  
  function deposit(string comment) public payable {
    emit Deposit(msg.sender, msg.value, comment);
  }

  function withdraw(uint256 amount, string comment) onlyOwner public {
    _transferEther(sink, amount);
    emit Withdraw(sink, amount, comment);
  }

  function _transferEther(address _to, uint _value) internal {
    address contractAddress = this;
    require(contractAddress.balance >= _value);
    _to.transfer(_value);
  }
}
