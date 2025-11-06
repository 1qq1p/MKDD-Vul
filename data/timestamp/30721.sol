pragma solidity 0.4.24;








contract TokenSaleForAlreadyDeployedERC20Tokens is FinalizableCrowdsale, Pausable {
    uint256 public crowdsaleCap;
    
    uint256 public starRaised;
    uint256 public starRate;
    bool public isWeiAccepted;

    
    Whitelist public whitelist;
    ERC20 public starToken;
    
    ERC20 public tokenOnSale;

    event TokenRateChanged(uint256 previousRate, uint256 newRate);
    event TokenStarRateChanged(uint256 previousStarRate, uint256 newStarRate);
    event TokenPurchaseWithStar(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    












    function init(
        uint256 _startTime,
        uint256 _endTime,
        address _whitelist,
        address _starToken,
        address _tokenOnSale,
        uint256 _rate,
        uint256 _starRate,
        address _wallet,
        uint256 _crowdsaleCap,
        bool    _isWeiAccepted
    )
        external
    {
        require(
            whitelist == address(0) &&
            starToken == address(0) &&
            rate == 0 &&
            starRate == 0 &&
            tokenOnSale == address(0) &&
            crowdsaleCap == 0,
            "Global variables should not have been set before!"
        );

        require(
            _whitelist != address(0) &&
            _starToken != address(0) &&
            !(_rate == 0 && _starRate == 0) &&
            _tokenOnSale != address(0) &&
            _crowdsaleCap != 0,
            "Parameter variables cannot be empty!"
        );

        initCrowdsale(_startTime, _endTime, _rate, _wallet);
        tokenOnSale = ERC20(_tokenOnSale);
        whitelist = Whitelist(_whitelist);
        starToken = ERC20(_starToken);
        starRate = _starRate;
        isWeiAccepted = _isWeiAccepted;
        owner = tx.origin;

        crowdsaleCap = _crowdsaleCap;
    }

    modifier isWhitelisted(address beneficiary) {
        require(whitelist.allowedAddresses(beneficiary), "Beneficiary not whitelisted!");
        _;
    }

    


    function () external payable {
        revert("No fallback function defined!");
    }

    



    function setRate(uint256 newRate) external onlyOwner {
        require(newRate != 0, "ETH rate must be more than 0");

        emit TokenRateChanged(rate, newRate);
        rate = newRate;
    }

    



    function setStarRate(uint256 newStarRate) external onlyOwner {
        require(newStarRate != 0, "Star rate must be more than 0!");

        emit TokenStarRateChanged(starRate, newStarRate);
        starRate = newStarRate;
    }

    


    function setIsWeiAccepted(bool _isWeiAccepted) external onlyOwner {
        require(rate != 0, "When accepting Wei you need to set a conversion rate!");
        isWeiAccepted = _isWeiAccepted;
    }

    



    function buyTokens(address beneficiary)
        public
        payable
        whenNotPaused
        isWhitelisted(beneficiary)
    {
        require(beneficiary != address(0));
        require(validPurchase() && tokenOnSale.balanceOf(address(this)) > 0);

        if (!isWeiAccepted) {
            require(msg.value == 0);
        } else if (msg.value > 0) {
            buyTokensWithWei(beneficiary);
        }

        
        uint256 starAllocationToTokenSale = starToken.allowance(beneficiary, address(this));
        if (starAllocationToTokenSale > 0) {
            
            uint256 tokens = starAllocationToTokenSale.mul(starRate);

            
            if (tokens > tokenOnSale.balanceOf(address(this))) {
                tokens = tokenOnSale.balanceOf(address(this));

                starAllocationToTokenSale = tokens.div(starRate);
            }

            
            starRaised = starRaised.add(starAllocationToTokenSale);

            tokenOnSale.transfer(beneficiary, tokens);
            emit TokenPurchaseWithStar(msg.sender, beneficiary, starAllocationToTokenSale, tokens);

            
            starToken.transferFrom(beneficiary, wallet, starAllocationToTokenSale);
        }
    }

    



    function buyTokensWithWei(address beneficiary)
        internal
    {
        uint256 weiAmount = msg.value;
        uint256 weiRefund = 0;

        
        uint256 tokens = weiAmount.mul(rate);

        
        if (tokens > tokenOnSale.balanceOf(address(this))) {
            tokens = tokenOnSale.balanceOf(address(this));
            weiAmount = tokens.div(rate);

            weiRefund = msg.value.sub(weiAmount);
        }

        
        weiRaised = weiRaised.add(weiAmount);

        tokenOnSale.transfer(beneficiary, tokens);
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        wallet.transfer(weiAmount);
        if (weiRefund > 0) {
            msg.sender.transfer(weiRefund);
        }
    }

    
    
    function hasEnded() public view returns (bool) {
        if (tokenOnSale.balanceOf(address(this)) == uint(0) && (starRaised > 0 || weiRaised > 0)) {
            return true;
        }

        return super.hasEnded();
    }

    



    function validPurchase() internal view returns (bool) {
        return now >= startTime && now <= endTime;
    }

    


    function finalization() internal {
        if (tokenOnSale.balanceOf(address(this)) > 0) {
            uint256 remainingTokens = tokenOnSale.balanceOf(address(this));

            tokenOnSale.transfer(wallet, remainingTokens);
        }

        super.finalization();
    }
}