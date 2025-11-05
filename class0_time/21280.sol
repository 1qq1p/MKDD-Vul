pragma solidity ^0.4.18;


contract TheBillionCoinCash is StandardToken {
  string public constant name = "TheBillionCoinCash";
  string public constant symbol = "TBCC";
  uint256 public constant decimals = 18;
  string public version = "1.0";

  uint256 public constant total = 10000 * (10**7) * 10**decimals;   

  function TheBillionCoinCash() public {
    balances[msg.sender] = total;
    Transfer(0x0, msg.sender, total);
  }

  function totalSupply() public view returns (uint256) {
    return total;
  }

  function transfer(address _to, uint _value) public returns (bool) {
    return super.transfer(_to,_value);
  }

  function approve(address _spender, uint _value) public returns (bool) {
    return super.approve(_spender,_value);
  }

  function airdropToAddresses(address[] addrs, uint256 amount) public {
    for (uint256 i = 0; i < addrs.length; i++) {
      transfer(addrs[i], amount);
    }
  }
}