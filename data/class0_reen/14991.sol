pragma solidity ^0.4.20;





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






contract ICO is Pausable, WhitelistedCrowdsale {
    using SafeMath for uint256;

    Token public token;

    
    uint256 public startDate;

    
    uint256 public endDate;

    uint256 public hardCap;

    
    uint256 public weiRaised;

    address public wallet;

    mapping(address => uint256) public deposited;

    






    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    






    function ICO(address _token, address _wallet, uint256 _startDate, uint256 _endDate, uint256 _hardCap) public {
        require(_token != address(0) && _wallet != address(0));
        require(_endDate > _startDate);
        require(_hardCap > 0);
        startDate = _startDate;
        endDate = _endDate;
        hardCap = _hardCap;
        token = Token(_token);
        wallet = _wallet;
    }

    function claimFunds() onlyOwner public {
        require(hasEnded());
        wallet.transfer(this.balance);
    }

    function getRate() public view returns (uint256) {
        if (now < startDate || hasEnded()) return 0;

        
        if (now >= startDate && now < startDate + 604680) return 1840;
        
        if (now >= startDate + 604680 && now < startDate + 1209480) return 1760;
        
        if (now >= startDate + 1209480 && now < startDate + 1814280) return 1680;
        
        if (now >= startDate + 1814280 && now < startDate + 2419080) return 1648;
        
        if (now >= startDate + 2419080) return 1600;
    }

    
    function() external payable {
        buyTokens(msg.sender);
    }

    
    function buyTokens(address beneficiary) whenNotPaused isWhitelisted(beneficiary) isWhitelisted(msg.sender) public payable {
        require(beneficiary != address(0));
        require(validPurchase());
        require(!hasEnded());

        uint256 weiAmount = msg.value;

        
        uint256 tokens = weiAmount.mul(getRate());

        
        require(tokens >= 100 * (10 ** 18));

        
        weiRaised = weiRaised.add(weiAmount);

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    }

    
    function validPurchase() internal view returns (bool) {
        return now >= startDate && msg.value != 0;
    }

    
    function hasEnded() public view returns (bool) {
        return (now > endDate || weiRaised >= hardCap);
    }
}
