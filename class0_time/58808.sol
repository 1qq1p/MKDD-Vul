pragma solidity ^0.4.18;






contract BasicToken is ERC20Basic, Ownable {
  using SafeMath for uint256;

  struct BalancesStruct {
    uint256 amount;
    bool exist;
  }
  mapping(address => BalancesStruct) balances;
  address[] addressList;

  uint256 totalSupply_;

  function isExist(address accountAddress) internal constant returns(bool exist) {
      return balances[accountAddress].exist;
  }
  


  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }


  




  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender].amount);

    
    balances[msg.sender].amount = balances[msg.sender].amount.sub(_value);
    balances[_to].amount = balances[_to].amount.add(_value);
    if(!isExist(_to) && _to != owner){
      balances[_to].exist = true;
      addressList.push(_to);
    }
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  




  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner].amount;
  }

}




