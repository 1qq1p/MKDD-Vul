pragma solidity ^0.4.24;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract TokedoToken is ERC20Basic, ERC223TokenCompatible, StandardToken, HumanStandardToken, StartToken, BurnToken  {
    constructor() public {
        name = "Tokedo";
        symbol = "TKD";
        decimals = 18;
        totalSupply = 78750709292959827150083646;
        balances[msg.sender] = totalSupply;
        initialSupply = totalSupply;
    }
}