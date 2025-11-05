pragma solidity ^0.4.24;






contract SmartTokenController is TokenHolder {
    ISmartToken public token;   

    


    constructor(ISmartToken _token)
        public
        validAddress(_token)
    {
        token = _token;
    }

    
    modifier active() {
        require(token.owner() == address(this));
        _;
    }

    
    modifier inactive() {
        require(token.owner() != address(this));
        _;
    }

    






    function transferTokenOwnership(address _newOwner) public ownerOnly {
        token.transferOwnership(_newOwner);
    }

    



    function acceptTokenOwnership() public ownerOnly {
        token.acceptOwnership();
    }

    





    function disableTokenTransfers(bool _disable) public ownerOnly {
        token.disableTransfers(_disable);
    }

    







    function withdrawFromToken(IERC20Token _token, address _to, uint256 _amount) public ownerOnly {
        ITokenHolder(token).withdrawTokens(_token, _to, _amount);
    }
}





