pragma solidity ^0.4.16;


contract BcbCoin is Ownable, StandardToken {

    string public name;
    string public symbol;
    uint public decimals;                  
    uint public totalSupply;  


    
    function BcbCoin() public {
        totalSupply = 100 * (10**6) * (10**18); 
        balances[msg.sender] = totalSupply;
        name = "BCB";
        symbol = "BCB";
        decimals = 18;  
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

}