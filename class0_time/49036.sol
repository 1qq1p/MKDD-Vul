pragma solidity 0.4.21;






contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  


  modifier onlyPayloadSize(uint size) {
     require(msg.data.length >= size + 4);
     _;
  }

  




  function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public {
    balances[msg.sender] = balances[msg.sender].sub256(_value);
    balances[_to] = balances[_to].add256(_value);
    Transfer(msg.sender, _to, _value);
  }

  




  function balanceOf(address _owner) constant public returns (uint256 balance) {
    return balances[_owner];
  }

}







