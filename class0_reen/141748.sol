pragma solidity ^0.4.25;








contract DenverToken is DetailedERC20, CappedToken, PausableToken, Claimable, CanReclaimToken, TokenWithBlackList {
    using SafeMath for uint256;
    uint256 public constant INITIAL_SUPPLY = 5 * 10000 * 10000 * (10 ** 18);

    constructor()
    DetailedERC20("Denver", "DNVR", 18)
    CappedToken(10 * 10000 * 10000 * (10 ** 18))
    public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[owner] = INITIAL_SUPPLY;
        emit Transfer(address(0), owner, INITIAL_SUPPLY);
    }

    function transfer(address _to, uint256 _value) public whenNotPaused notBlackListed(msg.sender) returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused notBlackListed(_from) returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
}