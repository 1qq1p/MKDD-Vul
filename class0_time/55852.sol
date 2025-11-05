pragma solidity ^0.4.13;




contract TokenHolder is ITokenHolder, Owned {
    


    function TokenHolder() {
    }

    
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }
    
    modifier validAddressForSecond(address _address) {
        require(_address != 0x0);
        _;
    }

    
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
    }

    







    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
        public
        ownerOnly
        validAddress(_token)
        validAddressForSecond(_to)
        notThis(_to)
    {
        assert(_token.transfer(_to, _amount));
    }
}



