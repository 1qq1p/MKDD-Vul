pragma solidity ^0.4.18;








contract BaseICOToken is BaseFixedERC20Token {

  
  uint public availableSupply;

  
  address public ico;

  
  event ICOTokensInvested(address indexed to, uint amount);

  
  event ICOChanged(address indexed icoContract);

  



  function BaseICOToken(uint totalSupply_) public {
    locked = true;
    totalSupply = totalSupply_;
    availableSupply = totalSupply_;
  }

  




  function changeICO(address ico_) onlyOwner public {
    ico = ico_;
    ICOChanged(ico);
  }

  function isValidICOInvestment(address to_, uint amount_) internal view returns(bool) {
    return msg.sender == ico && to_ != address(0) && amount_ <= availableSupply;
  }

  




  function icoInvestment(address to_, uint amount_) public returns (uint) {
    require(isValidICOInvestment(to_, amount_));
    availableSupply -= amount_;
    balances[to_] = balances[to_].add(amount_);
    ICOTokensInvested(to_, amount_);
    return amount_;
  }
}





