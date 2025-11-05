pragma solidity 0.4.24;





contract MyAdvancedToken is TokenERC20 {
    mapping (address => bool) public frozenAccount;

    
    event FrozenFunds(address target, bool frozen);

    
    constructor() TokenERC20() public {}

    
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);                               
        require(balanceOf[_from] >= _value);               
        require(balanceOf[_to] + _value > balanceOf[_to]); 
        require(!frozenAccount[_from]);                     
        require(!frozenAccount[_to]);                       
        balanceOf[_from] -= _value;                         
        balanceOf[_to] += _value;                           
        emit Transfer(_from, _to, _value);
    }

    
    
    
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        uint tempSupply = totalSupply;
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        require(totalSupply >= tempSupply);
        emit Transfer(0, this, mintedAmount);
        emit Transfer(this, target, mintedAmount);
    }

    
    
    
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    function () payable public {
        require(false);
    }

}
