pragma solidity ^0.4.23;





library SafeMath {

    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}









contract FBT is PausableToken  {

    using SafeMath for uint256;
    uint public lastMiningTime;
    uint public mineral;
    uint public lastMineralUpdateTime;
    string public  name;
    string public  symbol;
    uint8 public  decimals;

    function mining() public onlyMiner returns (uint){
        require(now - lastMiningTime > 6 days);

        if (now - lastMineralUpdateTime > 4 years) {
            mineral = mineral.div(2);
            lastMineralUpdateTime = now;
        }
        balances[msg.sender] = balances[msg.sender].add(mineral);
        lastMiningTime = now;

        Transfer(0x0, msg.sender, mineral);
        return mineral;
    }

    constructor() public {
        lastMineralUpdateTime = now;
        mineral = 520000000 * (10 ** 18);
        name = "FutureBit Token";
        symbol = "FBT";
        decimals = 18;
        totalSupply_ = 2100 * (10 ** 8) * (10 ** 18);
    }

}