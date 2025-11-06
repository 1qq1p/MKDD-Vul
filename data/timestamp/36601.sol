pragma solidity ^0.4.19;


contract Airdrop is Ownable {
    
    TokenInterface token;
    
    event NewTokenAddress(address indexed ERC20_ADDRESS);
    event TokensWithdrawn(address indexed ERC20_ADDRESS, uint256 TOTAL);
    event AirdropInvoked();
    
    





    function setTokenAddress(address _newTokenAddress) public onlyOwner returns(bool) {
        require(_newTokenAddress != address(token));
        require(_newTokenAddress != address(0));
        token = TokenInterface(_newTokenAddress);
        NewTokenAddress(_newTokenAddress);
        return true;
    }
    

    







    function multiValueAirDrop(address[] _addrs, uint256[] _values) public onlyOwner returns(bool) {
	    require(_addrs.length == _values.length && _addrs.length <= 100);
        for (uint i = 0; i < _addrs.length; i++) {
            if (_addrs[i] != 0x0 && _values[i] > 0) {
                token.transfer(_addrs[i], _values[i]);  
            }
        }
        AirdropInvoked();
        return true;
    }


    






    function singleValueAirDrop(address[] _addrs, uint256 _value) public onlyOwner returns(bool){
	    require(_addrs.length <= 100 && _value > 0);
        for (uint i = 0; i < _addrs.length; i++) {
            if (_addrs[i] != 0x0) {
                token.transfer(_addrs[i], _value);
            }
        }
        AirdropInvoked();
        return true;
    }
    
    
    





    function withdrawTokens(address _addressOfToken) public onlyOwner returns(bool) {
        TokenInterface tkn = TokenInterface(_addressOfToken);
        if(tkn.balanceOf(address(this)) == 0) {
            revert();
        }
        TokensWithdrawn(_addressOfToken, tkn.balanceOf(address(this)));
        tkn.transfer(owner, tkn.balanceOf(address(this)));
    }
}