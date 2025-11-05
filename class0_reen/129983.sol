pragma solidity ^0.4.16;


contract CTCoin is Ownable, StandardToken {

    string public name;
    string public symbol;
    uint public decimals;                  
    uint public totalSupply;  


    
    function CTCoin() public {
    totalSupply = 100 * (10**6) * (10**6);
        balances[msg.sender] = totalSupply;
        name = "CT";
        symbol = "CT";
        decimals = 6;
    }

    function () payable public{
    }

    
    
    function transferOwnership(address _newOwner) public onlyOwner {
        balances[_newOwner] = safeAdd(balances[owner], balances[_newOwner]);
        balances[owner] = 0;
        Ownable.transferOwnership(_newOwner);
    }

    
    function transferAnyERC20Token(address tokenAddress, uint amount) public onlyOwner returns (bool success)
    {
        return ERC20(tokenAddress).transfer(owner, amount);
    }
    
    function freezeAccount(address target, bool freeze) public onlyOwner  {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
    
    function mintToken(address _toAcct, uint256 _value) public onlyOwner  {
        balances[_toAcct] = safeAdd(balances[_toAcct], _value);
        totalSupply = safeAdd(totalSupply, _value);
        Transfer(0, this, _value);
        Transfer(this, _toAcct, _value);
    }

}