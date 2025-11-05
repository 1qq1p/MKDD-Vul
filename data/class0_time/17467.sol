

pragma solidity 0.4.24;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns(uint256 c) {
        if(a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Crowdsale is Manageable, Withdrawable, Pausable {
    using SafeMath for uint;

    Token public token;
    bool public crowdsaleClosed = false;

    event ExternalPurchase(address indexed holder, string tx, string currency, uint256 currencyAmount, uint256 rateToEther, uint256 tokenAmount);
    event CrowdsaleClose();
   
    constructor() public {
        token = new Token();

        addManager(0x915c517cB57fAB7C532262cB9f109C875bEd7d18);
    }

    function externalPurchase(address _to, string _tx, string _currency, uint _value, uint256 _rate, uint256 _tokens) whenNotPaused onlyManager public {
        token.mint(_to, _tokens);
        emit ExternalPurchase(_to, _tx, _currency, _value, _rate, _tokens);
    }

    function closeCrowdsale(address _to) onlyOwner public {
        require(!crowdsaleClosed);

        token.finishMinting();
        token.transferOwnership(_to);

        crowdsaleClosed = true;

        emit CrowdsaleClose();
    }
}