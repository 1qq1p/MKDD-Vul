pragma solidity 0.4.19;






contract OrigamiTokenSale is Ownable, CappedCrowdsale, WhitelistedCrowdsale {
    
    uint private constant HARD_CAP_IN_WEI = 5000 ether;
    uint private constant HARD_CAP_IN_WEI_PRESALE = 1000 ether;

    
    uint private constant BONUS_TWENTY_AMOUNT = 200 ether;
    uint private constant BONUS_TEN_AMOUNT = 100 ether;
    uint private constant BONUS_FIVE_AMOUNT = 50 ether;   
    
    
    uint private constant MINIMUM_INVEST_IN_WEI_PRESALE = 0.5 ether;
    uint private constant CONTRIBUTOR_MAX_PRESALE_CONTRIBUTION = 50 ether;
    uint private constant MINIMUM_INVEST_IN_WEI_SALE = 0.1 ether;
    uint private constant CONTRIBUTOR_MAX_SALE_CONTRIBUTION = 500 ether;

    
    address private constant ORIGAMI_WALLET = 0xf498ED871995C178a5815dd6D80AE60e1c5Ca2F4;
    
    
    address private constant BOUNTY_WALLET = 0xDBA7a16383658AeDf0A28Eabf2032479F128f26D;
    uint private constant BOUNTY_AMOUNT = 3000000e18;

    
    uint private constant PERIOD_AFTERSALE_NOT_TRANSFERABLE_IN_SEC = 7 days;    

    
    uint private constant TOTAL_ORI_TOKEN_SUPPLY = 50000000;

    
    uint private constant RATE_ETH_ORI = 6000;
    

    
    uint256 public presaleStartTime;
    uint256 public presaleEndTime;
    uint256 private presaleEndedAt;
    uint256 public preSaleWeiRaised;
    
    
    uint public firstWeekEndTime;
    uint public secondWeekEndTime;  
    
    
    
    mapping(address => uint256) wei_invested_by_contributor_in_presale;
    mapping(address => uint256) wei_invested_by_contributor_in_sale;

    event OrigamiTokenPurchase(address indexed beneficiary, uint256 value, uint256 final_tokens, uint256 initial_tokens, uint256 bonus);

    function OrigamiTokenSale(uint256 _presaleStartTime, uint256 _presaleEndTime, uint256 _startTime, uint256 _endTime, uint256 _firstWeekEndTime, uint256 _secondWeekEndTime) public
      WhitelistedCrowdsale()
      CappedCrowdsale(HARD_CAP_IN_WEI)
      StandardCrowdsale(_startTime, _endTime, RATE_ETH_ORI, ORIGAMI_WALLET)
    {
        
        token = createTokenContract();
        
        presaleStartTime = _presaleStartTime;
        presaleEndTime = _presaleEndTime;
        firstWeekEndTime = _firstWeekEndTime;
        secondWeekEndTime = _secondWeekEndTime;

        
        token.transfer(BOUNTY_WALLET, BOUNTY_AMOUNT);
    }
    
    


    function preSaleOpen() 
        public
        view 
        returns(bool)
    {
        return (now >= presaleStartTime && now <= presaleEndTime && preSaleWeiRaised < HARD_CAP_IN_WEI_PRESALE);
    }
    
    


    function preSaleEndedAt() 
        public
        view 
        returns(uint256)
    {
        return presaleEndedAt;
    }
    
    


    function saleOpen() 
        public
        view 
        returns(bool)
    {
        return (now >= startTime && now <= endTime);
    }
    
    



    function getInvestedAmount(address _address)
    public
    view
    returns (uint256)
    {
        uint256 investedAmount = wei_invested_by_contributor_in_presale[_address];
        investedAmount = investedAmount.add(wei_invested_by_contributor_in_sale[_address]);
        return investedAmount;
    }

    



    function getBonusFactor(uint256 _weiAmount)
        private view returns(uint256)
    {
        
        uint256 bonus = 0;

        
        if(now >= presaleStartTime && now <= presaleEndTime) {
            bonus = 15;
        
        } else {        
          
          if(_weiAmount >= BONUS_TWENTY_AMOUNT) {
              bonus = 20;
          }
          
          else if(_weiAmount >= BONUS_TEN_AMOUNT || now <= firstWeekEndTime) {
              bonus = 10;
          }
          
          else if(_weiAmount >= BONUS_FIVE_AMOUNT || now <= secondWeekEndTime) {
              bonus = 5;
          }
        }
        
        return bonus;
    }
    
    
    function buyTokens() 
       public 
       payable 
    {
        require(validPurchase());
        uint256 weiAmount = msg.value;

        
        uint256 tokens = weiAmount.mul(rate);

        
        uint256 bonus = getBonusFactor(weiAmount);
        
        
        uint256 final_bonus_amount = (tokens * bonus) / 100;
        
         
        uint256 final_tokens = tokens.add(final_bonus_amount);
        
        require(token.transfer(msg.sender, final_tokens)); 

         
        OrigamiTokenPurchase(msg.sender, weiAmount, final_tokens, tokens, final_bonus_amount);

        
        forwardFunds();

        
        weiRaised = weiRaised.add(weiAmount);

        
        if (preSaleOpen()) {
            wei_invested_by_contributor_in_presale[msg.sender] =  wei_invested_by_contributor_in_presale[msg.sender].add(weiAmount);
            preSaleWeiRaised = preSaleWeiRaised.add(weiAmount);
            if(weiRaised >= HARD_CAP_IN_WEI_PRESALE){
                presaleEndedAt = now;
            }
        }else{
            wei_invested_by_contributor_in_sale[msg.sender] =  wei_invested_by_contributor_in_sale[msg.sender].add(weiAmount);  
            if(weiRaised >= HARD_CAP_IN_WEI){
              endTime = now;
            }
        }
    }


    



    function createTokenContract () 
      internal 
      returns(StandardToken) 
    {
        return new OrigamiToken(TOTAL_ORI_TOKEN_SUPPLY, endTime.add(PERIOD_AFTERSALE_NOT_TRANSFERABLE_IN_SEC), ORIGAMI_WALLET, BOUNTY_WALLET);
    }

    
    function () external
       payable 
    {
        buyTokens();
    }
    
    



    function getContributorRemainingPresaleAmount(address wallet) public view returns(uint256) {
        uint256 invested_amount =  wei_invested_by_contributor_in_presale[wallet];
        return CONTRIBUTOR_MAX_PRESALE_CONTRIBUTION - invested_amount;
    }
    
        



    function getContributorRemainingSaleAmount(address wallet) public view returns(uint256) {
        uint256 invested_amount =  wei_invested_by_contributor_in_sale[wallet];
        return CONTRIBUTOR_MAX_SALE_CONTRIBUTION - invested_amount;
    }

    




    function drainRemainingToken () 
      public
      onlyOwner
    {
        require(hasEnded());
        token.transfer(ORIGAMI_WALLET, token.balanceOf(this));
    }
    
    


    function validPurchase () internal view returns(bool) 
    {
        
        if (preSaleOpen()) {
            
            if(preSaleWeiRaised > HARD_CAP_IN_WEI_PRESALE){
                return false;
            }
            
            if(msg.value < MINIMUM_INVEST_IN_WEI_PRESALE){
                 return false;
            }
            
            uint256 maxInvestAmount = getContributorRemainingPresaleAmount(msg.sender);
            if(msg.value > maxInvestAmount){
              return false;
            }
        }else if(saleOpen()){
            
            if(msg.value < MINIMUM_INVEST_IN_WEI_SALE){
                 return false;
            }
            
             
             uint256 maxInvestAmountSale = getContributorRemainingSaleAmount(msg.sender);
             if(msg.value > maxInvestAmountSale){
               return false;
            }
        }else{
            return false;
        }

        
        bool nonZeroPurchase = msg.value != 0;
        return super.validPurchase() && nonZeroPurchase;
    }

}