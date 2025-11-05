pragma solidity ^0.4.23;








contract Pausable223Token is ERC223, PausableToken {
  
  function transfer(address _to, uint _value, bytes _data) public returns (bool success) {
    
    if (!super.transfer(_to, _value)) revert(); 
    if (isContract(_to)) contractFallback(msg.sender, _to, _value, _data);
    emit Transfer(msg.sender, _to, _value, _data);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value, bytes _data) public returns (bool success) {
    if (!super.transferFrom(_from, _to, _value)) revert(); 
    if (isContract(_to)) contractFallback(_from, _to, _value, _data);
    emit Transfer(_from, _to, _value, _data);
    return true;
  }

  function transfer(address _to, uint _value) public returns (bool success) {
    return transfer(_to, _value, new bytes(0));
  }

  function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
    return transferFrom(_from, _to, _value, new bytes(0));
  }

  
  function contractFallback(address _origin, address _to, uint _value, bytes _data) private {
    ERC223Receiver reciever = ERC223Receiver(_to);
    reciever.tokenFallback(_origin, _value, _data);
  }

  
  function isContract(address _addr) private view returns (bool is_contract) {
    
    uint length;
    assembly { length := extcodesize(_addr) }
    return length > 0;
  }
}








pragma solidity ^0.4.23;





