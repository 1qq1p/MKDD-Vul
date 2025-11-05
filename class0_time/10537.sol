pragma solidity ^0.4.11;






























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
}






contract CATCrowdsale is FinalizableCrowdsale, TokensCappedCrowdsale(CATCrowdsale.CAP), PausableCrowdsale(true), BonusCrowdsale(CATCrowdsale.TOKEN_USDCENT_PRICE) {

    
    uint256 public constant DECIMALS = 18;
    uint256 public constant CAP = 2 * (10**9) * (10**DECIMALS);              
    uint256 public constant BITCLAVE_AMOUNT = 1 * (10**9) * (10**DECIMALS);  
    uint256 public constant TOKEN_USDCENT_PRICE = 10;                        

    
    address public remainingTokensWallet;
    address public presaleWallet;

    




    function setRate(uint256 _rate) external onlyOwner {
        require(_rate != 0x0);
        rate = _rate;
        RateChange(_rate);
    }

    


    function setEndTime(uint256 _endTime) external onlyOwner {
        require(!isFinalized);
        require(_endTime >= startTime);
        require(_endTime >= now);
        endTime = _endTime;
    }

    


    function setWallet(address _wallet) external onlyOwner {
        require(_wallet != 0x0);
        wallet = _wallet;
    }

    


    function setRemainingTokensWallet(address _remainingTokensWallet) external onlyOwner {
        require(_remainingTokensWallet != 0x0);
        remainingTokensWallet = _remainingTokensWallet;
    }

    
    event RateChange(uint256 rate);

    








    function CATCrowdsale(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        address _wallet,
        address _remainingTokensWallet,
        address _bitClaveWallet
    ) public
        Crowdsale(_startTime, _endTime, _rate, _wallet)
    {
        remainingTokensWallet = _remainingTokensWallet;
        presaleWallet = this;

        
        mintTokens(_bitClaveWallet, BITCLAVE_AMOUNT);
    }

    

    



    function createTokenContract() internal returns(MintableToken) {
        PreCAToken token = new PreCAToken();
        token.pause();
        return token;
    }

    


    function finalization() internal {
        super.finalization();

        
        if (token.totalSupply() < tokensCap) {
            uint tokens = tokensCap.sub(token.totalSupply());
            token.mint(remainingTokensWallet, tokens);
        }

        
        token.finishMinting();

        
        token.transferOwnership(owner);
    }

    

    


    function pauseTokens() public onlyOwner {
        PreCAToken(token).pause();
    }

    


    function unpauseTokens() public onlyOwner {
        PreCAToken(token).unpause();
    }

    


    function mintPresaleTokens(uint256 tokens) public onlyOwner {
        mintTokens(presaleWallet, tokens);
        presaleWallet = 0;
    }

    


    function transferPresaleTokens(address destination, uint256 amount) public onlyOwner {
        unpauseTokens();
        token.transfer(destination, amount);
        pauseTokens();
    }

    
    



    function mintTokens(address beneficiary, uint256 tokens) public onlyOwner {
        require(beneficiary != 0x0);
        require(tokens > 0);
        require(now <= endTime);                               
        require(!isFinalized);                                 
        require(token.totalSupply().add(tokens) <= tokensCap); 
        
        token.mint(beneficiary, tokens);
    }

}