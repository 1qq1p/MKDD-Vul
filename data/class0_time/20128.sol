pragma solidity ^0.4.24;


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}


contract NZOCrowdsale is Ownable, Crowdsale, MintableToken {
    using SafeMath for uint256;

    
    
    
    
    
    
    uint256 public rate  = 58517; 
    

    mapping (address => uint256) public deposited;

    uint256 public constant INITIAL_SUPPLY = 21 * 10**9 * (10 ** uint256(decimals));
    uint256 public    fundForSale = 12600 * 10**6 * (10 ** uint256(decimals));
    uint256 public    fundReserve = 5250000000 * (10 ** uint256(decimals));
    uint256 public fundFoundation = 1000500000 * (10 ** uint256(decimals));
    uint256 public       fundTeam = 2100000000 * (10 ** uint256(decimals));

    uint256 limitWeekZero = 2500000000 * (10 ** uint256(decimals));
    uint256 limitWeekOther = 200000000 * (10 ** uint256(decimals));
    
    

    address public addressFundReserve = 0x67446E0673418d302dB3552bdF05363dB5Fda9Ce;
    address public addressFundFoundation = 0xfe3859CB2F9d6f448e9959e6e8Fe0be841c62459;
    address public addressFundTeam = 0xfeD3B7eaDf1bD15FbE3aA1f1eAfa141efe0eeeb2;

    uint256 public startTime = 1530720000; 
    
    uint numberWeeks = 46;


    uint256 public countInvestor;

    event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);
    event TokenLimitReached(uint256 tokenRaised, uint256 purchasedToken);
    event MinWeiLimitReached(address indexed sender, uint256 weiAmount);
    event Finalized();

    constructor(address _owner) public
    Crowdsale(_owner)
    {
        require(_owner != address(0));
        owner = _owner;
        
        transfersEnabled = true;
        mintingFinished = false;
        totalSupply = INITIAL_SUPPLY;
        bool resultMintForOwner = mintForOwner(owner);
        require(resultMintForOwner);
    }

    
    function() payable public {
        buyTokens(msg.sender);
    }

    function buyTokens(address _investor) public payable returns (uint256){
        require(_investor != address(0));
        uint256 weiAmount = msg.value;
        uint256 tokens = validPurchaseTokens(weiAmount);
        if (tokens == 0) {revert();}
        weiRaised = weiRaised.add(weiAmount);
        tokenAllocated = tokenAllocated.add(tokens);
        mint(_investor, tokens, owner);

        emit TokenPurchase(_investor, weiAmount, tokens);
        if (deposited[_investor] == 0) {
            countInvestor = countInvestor.add(1);
        }
        deposit(_investor);
        wallet.transfer(weiAmount);
        return tokens;
    }

    function getTotalAmountOfTokens(uint256 _weiAmount) internal returns (uint256) {
        uint256 currentDate = now;
        
        
        uint currentPeriod = getPeriod(currentDate);
        uint256 amountOfTokens = 0;
        if(currentPeriod < 100){
            if(currentPeriod == 0){
                amountOfTokens = _weiAmount.mul(rate).div(4);
                if (tokenAllocated.add(amountOfTokens) > limitWeekZero) {
                    emit TokenLimitReached(tokenAllocated, amountOfTokens);
                    return 0;
                }
            }
            for(uint j = 0; j < numberWeeks; j++){
                if(currentPeriod == (j + 1)){
                    amountOfTokens = _weiAmount.mul(rate).div(5+j*25);
                    if (tokenAllocated.add(amountOfTokens) > limitWeekZero + limitWeekOther.mul(j+1)) {
                        emit TokenLimitReached(tokenAllocated, amountOfTokens);
                        return 0;
                    }
                }
            }
        }
        return amountOfTokens;
    }

    function getPeriod(uint256 _currentDate) public view returns (uint) {
        if( startTime > _currentDate && _currentDate > startTime + 365 days){
            return 100;
        }
        if( startTime <= _currentDate && _currentDate <= startTime + 43 days){
            return 0;
        }
        for(uint j = 0; j < numberWeeks; j++){
            if( startTime + 43 days + j*7 days <= _currentDate && _currentDate <= startTime + 43 days + (j+1)*7 days){
                return j + 1;
            }
        }
        return 100;
    }

    function deposit(address investor) internal {
        deposited[investor] = deposited[investor].add(msg.value);
    }

    function mintForOwner(address _walletOwner) internal returns (bool result) {
        result = false;
        require(_walletOwner != address(0));
        balances[_walletOwner] = balances[_walletOwner].add(fundForSale);

        balances[addressFundTeam] = balances[addressFundTeam].add(fundTeam);
        balances[addressFundReserve] = balances[addressFundReserve].add(fundReserve);
        balances[addressFundFoundation] = balances[addressFundFoundation].add(fundFoundation);

        result = true;
    }

    function getDeposited(address _investor) public view returns (uint256){
        return deposited[_investor];
    }

    function validPurchaseTokens(uint256 _weiAmount) public returns (uint256) {
        uint256 addTokens = getTotalAmountOfTokens(_weiAmount);
        if (_weiAmount < 0.5 ether) {
            emit MinWeiLimitReached(msg.sender, _weiAmount);
            return 0;
        }
        if (tokenAllocated.add(addTokens) > fundForSale) {
            emit TokenLimitReached(tokenAllocated, addTokens);
            return 0;
        }
        return addTokens;
    }

    function finalize() public onlyOwner returns (bool result) {
        result = false;
        wallet.transfer(address(this).balance);
        finishMinting();
        emit Finalized();
        result = true;
    }

    function setRate(uint256 _newRate) external onlyOwner returns (bool){
        require(_newRate > 0);
        rate = _newRate;
        return true;
    }
}