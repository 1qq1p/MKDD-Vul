

















pragma solidity ^0.4.23;







contract MainToken is Consts, FreezableMintableToken, BurnableToken, Pausable
    
{
    

    function name() public pure returns (string _name) {
        return TOKEN_NAME;
    }

    function symbol() public pure returns (string _symbol) {
        return TOKEN_SYMBOL;
    }

    function decimals() public pure returns (uint8 _decimals) {
        return TOKEN_DECIMALS_UINT8;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool _success) {
        require(!paused);
        return super.transferFrom(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool _success) {
        require(!paused);
        return super.transfer(_to, _value);
    }

    
}



