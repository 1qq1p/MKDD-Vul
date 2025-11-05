pragma solidity ^0.4.23;








contract ModularBasicToken is HasOwner {
    using SafeMath for uint256;

    event BalanceSheetSet(address indexed sheet);
    event Transfer(address indexed from, address indexed to, uint256 value);

    



    function setBalanceSheet(address _sheet) public onlyOwner returns (bool) {
        balances = BalanceSheet(_sheet);
        balances.claimOwnership();
        emit BalanceSheetSet(_sheet);
        return true;
    }

    


    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    




    function transfer(address _to, uint256 _value) public returns (bool) {
        _transferAllArgs(msg.sender, _to, _value);
        return true;
    }


    function _transferAllArgs(address _from, address _to, uint256 _value) internal {
        
        balances.subBalance(_from, _value);
        balances.addBalance(_to, _value);
        emit Transfer(_from, _to, _value);
    }
    

    




    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances.balanceOf(_owner);
    }
}









