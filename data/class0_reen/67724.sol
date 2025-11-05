pragma solidity 0.4.18;








contract ODEMCrowdsale is FinalizableCrowdsale, Pausable {
    uint256 constant public BOUNTY_REWARD_SHARE =           43666667e18; 
    uint256 constant public VESTED_TEAM_ADVISORS_SHARE =    38763636e18; 
    uint256 constant public NON_VESTED_TEAM_ADVISORS_SHARE = 5039200e18; 
    uint256 constant public COMPANY_SHARE =                 71300194e18; 

    uint256 constant public PRE_CROWDSALE_CAP =      58200000e18; 
    uint256 constant public PUBLIC_CROWDSALE_CAP =  180000000e18; 
    uint256 constant public TOTAL_TOKENS_FOR_CROWDSALE = PRE_CROWDSALE_CAP + PUBLIC_CROWDSALE_CAP;
    uint256 constant public TOTAL_TOKENS_SUPPLY =   396969697e18; 
    uint256 constant public PERSONAL_FIRST_HOUR_CAP = 2000000e18; 

    address public rewardWallet;
    address public teamAndAdvisorsAllocation;
    uint256 public oneHourAfterStartTime;

    
    
    address public remainderPurchaser;
    uint256 public remainderAmount;

    mapping (address => uint256) public trackBuyersPurchases;

    
    Whitelist public whitelist;

    event PrivateInvestorTokenPurchase(address indexed investor, uint256 tokensPurchased);
    event TokenRateChanged(uint256 previousRate, uint256 newRate);

    








    function ODEMCrowdsale
        (
            uint256 _startTime,
            uint256 _endTime,
            address _whitelist,
            uint256 _rate,
            address _wallet,
            address _rewardWallet
        )
        public
        FinalizableCrowdsale()
        Crowdsale(_startTime, _endTime, _rate, _wallet)
    {

        require(_whitelist != address(0) && _wallet != address(0) && _rewardWallet != address(0));
        whitelist = Whitelist(_whitelist);
        rewardWallet = _rewardWallet;
        oneHourAfterStartTime = startTime.add(1 hours);

        ODEMToken(token).pause();
    }

    modifier whitelisted(address beneficiary) {
        require(whitelist.isWhitelisted(beneficiary));
        _;
    }

    



    function setRate(uint256 newRate) external onlyOwner {
        require(newRate != 0);

        TokenRateChanged(rate, newRate);
        rate = newRate;
    }

    




    function mintTokenForPreCrowdsale(address investorsAddress, uint256 tokensPurchased)
        external
        onlyOwner
    {
        require(now < startTime && investorsAddress != address(0));
        require(token.totalSupply().add(tokensPurchased) <= PRE_CROWDSALE_CAP);

        token.mint(investorsAddress, tokensPurchased);
        PrivateInvestorTokenPurchase(investorsAddress, tokensPurchased);
    }

    



    function setTeamWalletAddress(address _teamAndAdvisorsAllocation) public onlyOwner {
        require(_teamAndAdvisorsAllocation != address(0x0));
        teamAndAdvisorsAllocation = _teamAndAdvisorsAllocation;
    }

    



    function buyTokens(address beneficiary)
        public
        whenNotPaused
        whitelisted(beneficiary)
        payable
    {
        require(beneficiary != address(0));
        require(msg.sender == beneficiary);
        require(validPurchase() && token.totalSupply() < TOTAL_TOKENS_FOR_CROWDSALE);

        uint256 weiAmount = msg.value;

        
        uint256 tokens = weiAmount.mul(rate);

        
        if (now < oneHourAfterStartTime)
            require(trackBuyersPurchases[msg.sender].add(tokens) <= PERSONAL_FIRST_HOUR_CAP);

        trackBuyersPurchases[beneficiary] = trackBuyersPurchases[beneficiary].add(tokens);

        
        if (token.totalSupply().add(tokens) > TOTAL_TOKENS_FOR_CROWDSALE) {
            tokens = TOTAL_TOKENS_FOR_CROWDSALE.sub(token.totalSupply());
            weiAmount = tokens.div(rate);

            
            remainderPurchaser = msg.sender;
            remainderAmount = msg.value.sub(weiAmount);
        }

        
        weiRaised = weiRaised.add(weiAmount);

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

    
    
    function hasEnded() public view returns (bool) {
        if (token.totalSupply() == TOTAL_TOKENS_FOR_CROWDSALE) {
            return true;
        }

        return super.hasEnded();
    }

    


    function createTokenContract() internal returns (MintableToken) {
        return new ODEMToken();
    }

    


    function finalization() internal {
        
        require(teamAndAdvisorsAllocation != address(0x0));

        
        token.mint(teamAndAdvisorsAllocation, VESTED_TEAM_ADVISORS_SHARE);
        token.mint(wallet, NON_VESTED_TEAM_ADVISORS_SHARE);
        token.mint(wallet, COMPANY_SHARE);
        token.mint(rewardWallet, BOUNTY_REWARD_SHARE);

        if (TOTAL_TOKENS_SUPPLY > token.totalSupply()) {
            uint256 remainingTokens = TOTAL_TOKENS_SUPPLY.sub(token.totalSupply());

            token.mint(wallet, remainingTokens);
        }

        token.finishMinting();
        ODEMToken(token).unpause();
        super.finalization();
    }
}