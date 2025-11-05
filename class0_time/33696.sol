pragma solidity ^0.4.24;







contract Standard223Token is ERC223, StandardToken {
  
  function transfer(address _to, uint _value, bytes _data) returns (bool success) {
    
    if (!super.transfer(_to, _value)) throw; 
    if (isContract(_to)) return contractFallback(msg.sender, _to, _value, _data);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value, bytes _data) returns (bool success) {
    if (!super.transferFrom(_from, _to, _value)) throw; 
    if (isContract(_to)) return contractFallback(_from, _to, _value, _data);
    return true;
  }

  function transfer(address _to, uint _value) returns (bool success) {
    return transfer(_to, _value, new bytes(0));
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool success) {
    return transferFrom(_from, _to, _value, new bytes(0));
  }

  
  function contractFallback(address _origin, address _to, uint _value, bytes _data) private returns (bool success) {
    ERC223Receiver reciever = ERC223Receiver(_to);
    return reciever.tokenFallback(msg.sender, _origin, _value, _data);
  }

  
  function isContract(address _addr) private returns (bool is_contract) {
    
    uint length;
    assembly { length := extcodesize(_addr) }
    return length > 0;
  }
}


