



 
 pragma solidity ^0.4.10;














contract TokenTrancheWallet is TrancheWallet {

    
    IERC20Token public token;

    function TokenTrancheWallet(
        IERC20Token _token,
        address _beneficiary, 
        uint256 _tranchePeriodInDays,
        uint256 _trancheAmountPct
        ) TrancheWallet(_beneficiary, _tranchePeriodInDays, _trancheAmountPct) 
    {
        token = _token;
    }

    
    function currentBalance() internal constant returns(uint256) {
        return token.balanceOf(this);
    }

    
    function doTransfer(uint256 amount) internal {
        require(token.transfer(beneficiary, amount));
    }
}