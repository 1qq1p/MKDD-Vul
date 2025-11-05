pragma solidity ^0.4.21;







contract BonusToken is BurnableToken, Operational, StandardToken {
    using SafeMath for uint;
    using DateTime for uint256;

    uint256 public createTime;
    uint256 standardDecimals = 100000000;
    uint256 minMakeBonusAmount = standardDecimals.mul(10);

    function BonusToken() public Operational(msg.sender) {}

    function makeBonus(address[] _to, uint256[] _bonus) public returns(bool) {
        for(uint i = 0; i < _to.length; i++){
            require(transfer(_to[i], _bonus[i]));
        }
        return true;
    }

}

