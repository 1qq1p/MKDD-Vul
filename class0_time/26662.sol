pragma solidity ^0.4.18;





contract TokenHolder is ITokenHolder, Owned, Utils {
    


    function TokenHolder() public {
    }

    







    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
        public
        ownerOnly
        validAddress(_token)
        validAddress(_to)
        notThis(_to)
    {
        assert(_token.transfer(_to, _amount));
    }
}

