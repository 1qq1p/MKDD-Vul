pragma solidity ^0.4.23;





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






contract IndividuallyCappedCrowdsale is Crowdsale, CappedCrowdsale {
    using SafeMath for uint256;

    mapping(address => uint256) public contributions;
    uint256 public individualCap;
    uint256 public miniumInvestment;

    




    constructor(uint256 _individualCap, uint256 _miniumInvestment) public {
        require(_individualCap > 0);
        require(_miniumInvestment > 0);
        individualCap = _individualCap;
        miniumInvestment = _miniumInvestment;
    }


    




    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal view {
        super._preValidatePurchase(_beneficiary, _weiAmount);
        require(_weiAmount <= individualCap);
        require(_weiAmount >= miniumInvestment);
    }
}




