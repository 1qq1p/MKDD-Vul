pragma solidity ^0.4.18;

































contract FreezableERC20Token is ERC20Token, Freezable {
    







    function transfer(address _to, uint _value) public requireNotFrozen returns (bool success) {
        return super.transfer(_to, _value);
    }

    








    function transferFrom(address _from, address _to, uint _value) public requireNotFrozen returns (bool success) {
        return super.transferFrom(_from, _to, _value);
    }

    







    function approve(address _spender, uint _value) public requireNotFrozen returns (bool success) {
        return super.approve(_spender, _value);
    }

}








