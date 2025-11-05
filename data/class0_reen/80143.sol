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

contract Airdropper is MultisendableToken
{
    using SafeMath for uint256[];
    
    event Airdrop(uint256 tokensDropped, uint256 airdropCount);
    event AirdropFinished();
    
    uint256 public airdropsCount = 0;
    uint256 public airdropTotalSupply = 0;
    uint256 public airdropDistributedTokensAmount = 0;
    bool public airdropFinished = false;
    
    function airdropToken(address[] addresses, uint256[] values) 
        public
        onlyOwner
        returns(bool) 
    {
        require(!airdropFinished);
        uint256 totalSendAmount = values.getAllValuesSum();
        uint256 totalDropAmount = airdropDistributedTokensAmount
                                  + totalSendAmount;
        require(totalDropAmount <= airdropTotalSupply);
        massTransfer(addresses, values);
        airdropDistributedTokensAmount = totalDropAmount;
        airdropsCount++;
        
        emit Airdrop(totalSendAmount, airdropsCount);
        return true;
    }
    
    function finishAirdrops() public onlyOwner 
    {
        
        require(airdropDistributedTokensAmount == airdropTotalSupply);
        airdropFinished = true;
        emit AirdropFinished();
    }
}
