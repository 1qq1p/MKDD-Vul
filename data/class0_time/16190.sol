pragma solidity ^0.4.24;

library SafeMath 
{
    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 result = a * b;
        assert(a == 0 || result / a == b);
        return result;
    }
 
    function div(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 result = a / b;
        return result;
    }
 
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        assert(b <= a); 
        return a - b; 
    } 
  
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    { 
        uint256 result = a + b; 
        assert(result >= a);
        return result;
    }
 
    function getAllValuesSum(uint256[] values)
        internal
        pure
        returns(uint256)
    {
        uint256 result = 0;
        
        for (uint i = 0; i < values.length; i++)
        {
            result = add(result, values[i]);
        }
        return result;
    }
}

contract FreezableToken is BasicToken 
{
    event ChangeFreezePermission(address indexed who, bool permission);
    event FreezeTokens(address indexed who, uint256 freezeAmount);
    event UnfreezeTokens(address indexed who, uint256 unfreezeAmount);
    
    
    function giveFreezePermission(address[] owners, bool permission)
        public
        onlyOwner
        returns(bool)
    {
        for (uint i = 0; i < owners.length; i++)
        {
        wallets[owners[i]].canFreezeTokens = permission;
        emit ChangeFreezePermission(owners[i], permission);
        }
        return true;
    }
    
    function freezeAllowance(address owner)
        public
        view
        returns(bool)
    {
        return wallets[owner].canFreezeTokens;   
    }
    
    function freezeTokens(uint256 amount, uint unfreezeDate)
        public
        isFreezeAllowed
        returns(bool)
    {
        
        require(wallets[msg.sender].freezedAmount == 0
        && wallets[msg.sender].tokensAmount >= amount); 
        wallets[msg.sender].freezedAmount = amount;
        wallets[msg.sender].unfreezeDate = unfreezeDate;
        emit FreezeTokens(msg.sender, amount);
        return true;
    }
    
    function showFreezedTokensAmount(address owner)
    public
    view
    returns(uint256)
    {
        return wallets[owner].freezedAmount;
    }
    
    function unfreezeTokens()
        public
        returns(bool)
    {
        require(wallets[msg.sender].freezedAmount > 0
        && now >= wallets[msg.sender].unfreezeDate);
        emit UnfreezeTokens(msg.sender, wallets[msg.sender].freezedAmount);
        wallets[msg.sender].freezedAmount = 0; 
        wallets[msg.sender].unfreezeDate = 0;
        return true;
    }
    
    function showTokensUnfreezeDate(address owner)
    public
    view
    returns(uint)
    {
        
        return wallets[owner].unfreezeDate;
    }
    
    function getUnfreezedTokens(address owner)
    internal
    view
    returns(uint256)
    {
        return wallets[owner].tokensAmount - wallets[owner].freezedAmount;
    }
    
    modifier isFreezeAllowed()
    {
        require(freezeAllowance(msg.sender));
        _;
    }
}
