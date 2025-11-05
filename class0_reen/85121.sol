pragma solidity ^0.4.18;
 











contract DiXiEnergy is Limitedsale {
    string public standart = 'Token 0.1';
    string public name = 'DiXiEnergy';
    string public symbol = "DXE";
    uint8 public decimals = 2;

    
     modifier onlyPayloadSize(uint size) {
     if(msg.data.length < size + 4) {
       throw;
     }
     _;
  }
  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) {
    require(balanceOf[msg.sender] >= _value);
     balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;  
    Transfer(msg.sender, _to, _value);
  }
}
