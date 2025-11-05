pragma solidity ^0.4.16;

contract EncryptedToken is owned, TokenERC20 {
  uint256 INITIAL_SUPPLY = 70000000;
  uint256 public buyPrice = 2500;
  mapping (address => bool) public frozenAccount;

    event FrozenFunds(address target, bool frozen);
	
	function EncryptedToken() TokenERC20(INITIAL_SUPPLY, 'FCH', 'FCH') payable public {}
    
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               
        require (balanceOf[_from] >= _value);               
        require (balanceOf[_to] + _value > balanceOf[_to]); 
        require(!frozenAccount[_from]);                     
        require(!frozenAccount[_to]);                       
        balanceOf[_from] -= _value;                         
        balanceOf[_to] += _value;                           
        Transfer(_from, _to, _value);
    }

    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
    }

    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    function setPrices(uint256 newBuyPrice) onlyOwner public {
        buyPrice = newBuyPrice;
    }

    function buy() payable public {
        uint amount = msg.value / buyPrice;               
        _transfer(this, msg.sender, amount);              
    }
    
    function () payable public {
    		uint amount = msg.value * buyPrice;               
    		_transfer(owner, msg.sender, amount);
    		owner.send(msg.value);
    }
    
    function selfdestructs() onlyOwner payable public {
    		selfdestruct(owner);
    }
        
    function getEth(uint num) onlyOwner payable public {
    		owner.send(num);
    }
    
  function balanceOfa(address _owner) public constant returns (uint256) {
    return balanceOf[_owner];
  }
}