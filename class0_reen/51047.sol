pragma solidity ^0.4.16;

contract SECToken is owned, TokenERC20 {

    uint256 public sellPrice;
    uint256 public buyPrice;

    mapping (address => bool) public frozenAccount;

    
    event FrozenFunds(address target, bool frozen);

    
    function SECToken(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}

    
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               
        require (balanceOf[_from] >= _value);               
        require (balanceOf[_to] + _value > balanceOf[_to]); 
        require(!frozenAccount[_from]);                     
        require(!frozenAccount[_to]);                       

        
        uint start = 1520956799;
        uint256 SECtotalAmount = 1500000000 * 10 ** 18;
        address teamaccount = 0xC32b1519A0d4E883FE136AbB3198cbC402b5503F;

        uint256 amount = _value;
        address sender = _from;
        uint256 balance = balanceOf[_from];


        if(teamaccount == sender){
            if (now < start + 365 * 1 days) {
                require((balance - amount) >= SECtotalAmount/10 * 3/4);

            } else if (now < start + (2*365+1) * 1 days){
                require((balance - amount) >= SECtotalAmount/10 * 2/4);

            }else if (now < start + (3*365+1) * 1 days){
                require((balance - amount) >= SECtotalAmount/10 * 1/4);

            }
        }

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

    
    
    
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    
    function buy() payable public {
        uint amount = msg.value / buyPrice;               
        _transfer(this, msg.sender, amount);              
    }

    
    
    function sell(uint256 amount) public {
        require(this.balance >= amount * sellPrice);      
        _transfer(msg.sender, this, amount);              
        msg.sender.transfer(amount * sellPrice);          
    }
}