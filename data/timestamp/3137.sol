pragma solidity ^0.4.24;





library SafeMath {

    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        uint256 c = a / b;
        
        return c;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}







contract CrowdsaleCompatible is BasicERC20, Ownable
{
    BasicCrowdsale public crowdsale = BasicCrowdsale(0x0);

    
    function unfreezeTokens() public
    {
        assert(now > crowdsale.endTime());
        isTokenTransferable = true;
    }

    
    function initializeCrowdsale(address crowdsaleContractAddress, uint256 tokensAmount) onlyOwner public  {
        transfer((address)(0x0), tokensAmount);
        allowance[(address)(0x0)][crowdsaleContractAddress] = tokensAmount;
        crowdsale = BasicCrowdsale(crowdsaleContractAddress);
        isTokenTransferable = false;
        transferOwnership(0x0); 
    }
}






