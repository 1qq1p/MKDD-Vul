pragma solidity ^0.4.18;








contract TCoinToken is MintableToken, FallbackToken {

    string public constant name = "TCoin";

    string public constant symbol = "TCOIN";

    uint256 public constant decimals = 18;

    bool public released = false;

    event Release();

    modifier isReleased () {
        require(mintingFinished);
        require(released);
        _;
    }

    function TCoinToken(address owner) public {
        require(owner != address(0));
        mint(owner, 1000e18);
        finishMinting();
        release();
    }

    function release() internal returns (bool) {
        require(mintingFinished);
        require(!released);
        released = true;
        Release();

        return true;
    }

    function transfer(address _to, uint256 _value) public isReleased returns (bool) {
        require(super.transfer(_to, _value));

        if (isContract(_to)) {
            Receiver(_to).tokenFallback(msg.sender, _value);
        }

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public isReleased returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public isReleased returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public isReleased returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public isReleased returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

}