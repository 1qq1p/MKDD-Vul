pragma solidity ^0.4.13; 

contract GoramCoin is owned, token {

  uint256 public sellPrice;
  uint256 public buyPrice;

  mapping (address => bool) public frozenAccount;

  
  event FrozenFunds(address target, bool frozen);

  
  function GoramCoin(
      uint256 initialSupply,
      string tokenName,
      uint8 decimalUnits,
      string tokenSymbol
  ) token (initialSupply, tokenName, decimalUnits, tokenSymbol) {}

  
  function _transfer(address _from, address _to, uint _value) internal {
      require (_to != 0x0);                               
      require (balanceOf[_from] > _value);                
      require (balanceOf[_to] + _value > balanceOf[_to]); 
      require(!frozenAccount[_from]);                     
      require(!frozenAccount[_to]);                       
      balanceOf[_from] -= _value;                         
      balanceOf[_to] += _value;                           
      Transfer(_from, _to, _value);
  }

  
  
  
  function mintToken(address target, uint256 mintedAmount) onlyOwner {
      balanceOf[target] += mintedAmount;
      totalSupply += mintedAmount;
      Transfer(0, this, mintedAmount);
      Transfer(this, target, mintedAmount);
  }

  
  
  
  function freezeAccount(address target, bool freeze) onlyOwner {
      frozenAccount[target] = freeze;
      FrozenFunds(target, freeze);
  }

  
  
  
  function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner {
      sellPrice = newSellPrice;
      buyPrice = newBuyPrice;
  }

  
  function buy() payable {
      uint amount = msg.value / buyPrice;               
      _transfer(this, msg.sender, amount);              
  }
  
  
  function getBuy() returns (uint256){
      return buyPrice;          
  }
  
  
  function getSell() returns (uint256){
      return sellPrice;          
  }

  
  
  function sell(uint256 amount) {
      require(this.balance >= amount * sellPrice);      
      _transfer(msg.sender, this, amount);              
      msg.sender.transfer(amount * sellPrice);          
  }
}