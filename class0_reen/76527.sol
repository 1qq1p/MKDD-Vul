pragma solidity ^0.4.18;

contract QRG is owned, TokenERC20 {

    uint256 public buyPrice;
    bool public isContractFrozen;

    mapping (address => bool) public frozenAccount;

    
    event FrozenFunds(address target, bool frozen);
    event FrozenContract(bool frozen);

    
    function QRG(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}

    
    function _transfer(address _from, address _to, uint _value) internal {
        require (!isContractFrozen);
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

    function freezeContract(bool freeze) onlyOwner public {
        isContractFrozen = freeze;
        FrozenContract(freeze);           
    }

    function setPrice(uint256 newBuyPrice) onlyOwner public {
        buyPrice = newBuyPrice;
    }

    function () public payable {
        require (buyPrice != 0);                          
        uint amountTokens = msg.value*buyPrice;           
        _transfer(this, msg.sender, amountTokens);        
        owner.transfer(msg.value);
    }

    function withdrawTokens(uint256 amount) onlyOwner public{
        _transfer(this, msg.sender, amount);
    }

    function kill() onlyOwner public{
        selfdestruct(msg.sender);
    }
}