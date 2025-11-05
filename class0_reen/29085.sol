contract ERC20Basic {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function transfer(address to, uint value);
  event Transfer(address indexed from, address indexed to, uint value);
}

contract Token is StandardToken, Own {
  string public constant name = "TribeToken";
  string public constant symbol = "TRIBE";
  uint public constant decimals = 6;

  
  function Token() {
      totalSupply = 200000000000000;
      balances[msg.sender] = totalSupply; 
  }

  
  function burner(uint _value) onlyOwner returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Transfer(msg.sender, 0x0, _value);
    return true;
  }

}
