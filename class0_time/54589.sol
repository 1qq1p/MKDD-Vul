pragma solidity ^0.4.11;





contract ExoTownIco is SafeMath, IcoLimits {

    


    ExoTownToken public exotownToken;

    enum State {
        Pause,
        Running
    }

    State public currentState = State.Pause;

    uint public privateSaleSoldTokens = 0;
    uint public preSaleSoldTokens     = 0;
    uint public publicSaleSoldTokens  = 0;

    uint public privateSaleEtherRaised = 0;
    uint public preSaleEtherRaised     = 0;
    uint public publicSaleEtherRaised  = 0;

    
    address public icoManager;
    address public founderWallet;

    
    address public buyBack;

    
    address public developmentWallet;
    address public marketingWallet;
    address public teamWallet;

    address public bountyOwner;

    
    address public mediatorWallet;

    bool public sentTokensToBountyOwner = false;
    bool public sentTokensToFounders = false;

    

    



    modifier whenInitialized() {
        
        require(currentState >= State.Running);
        _;
    }

    modifier onlyManager() {
        
        require(msg.sender == icoManager);
        _;
    }

    modifier onIco() {
        require( isPrivateSale() || isPreSale() || isPublicSale() );
        _;
    }

    modifier hasBountyCampaign() {
        require(bountyOwner != 0x0);
        _;
    }

    function isPrivateSale() constant internal returns (bool) {
        return now >= privateSaleStart && now <= privateSaleEnd;
    }

    function isPreSale() constant internal returns (bool) {
        return now >= presaleStart && now <= presaleEnd;
    }

    function isPublicSale() constant internal returns (bool) {
        return now >= publicSaleStart && now <= publicSaleEnd;
    }







    function getPrice() constant internal returns (uint) {
        if (isPrivateSale()) return privateSalePrice;
        if (isPreSale()) return preSalePrice;
        if (isPublicSale()) return publicSalePrice;

        return publicSalePrice;
    }

    function getStageSupplyLimit() constant returns (uint) {
        if (isPrivateSale()) return privateSaleSupplyLimit;
        if (isPreSale()) return preSaleSupplyLimit;
        if (isPublicSale()) return publicSaleSupplyLimit;

        return 0;
    }

    function getStageSoldTokens() constant returns (uint) {
        if (isPrivateSale()) return privateSaleSoldTokens;
        if (isPreSale()) return preSaleSoldTokens;
        if (isPublicSale()) return publicSaleSoldTokens;

        return 0;
    }

    function addStageTokensSold(uint _amount) internal {
        if (isPrivateSale()) privateSaleSoldTokens = add(privateSaleSoldTokens, _amount);
        if (isPreSale())     preSaleSoldTokens = add(preSaleSoldTokens, _amount);
        if (isPublicSale())  publicSaleSoldTokens = add(publicSaleSoldTokens, _amount);
    }

    function addStageEtherRaised(uint _amount) internal {
        if (isPrivateSale()) privateSaleEtherRaised = add(privateSaleEtherRaised, _amount);
        if (isPreSale())     preSaleEtherRaised = add(preSaleEtherRaised, _amount);
        if (isPublicSale())  publicSaleEtherRaised = add(publicSaleEtherRaised, _amount);
    }

    function getStageEtherRaised() constant returns (uint) {
        if (isPrivateSale()) return privateSaleEtherRaised;
        if (isPreSale())     return preSaleEtherRaised;
        if (isPublicSale())  return publicSaleEtherRaised;

        return 0;
    }

    function getTokensSold() constant returns (uint) {
        return
            privateSaleSoldTokens +
            preSaleSoldTokens +
            publicSaleSoldTokens;
    }

    function getEtherRaised() constant returns (uint) {
        return
            privateSaleEtherRaised +
            preSaleEtherRaised +
            publicSaleEtherRaised;
    }















    
    
    function ExoTownIco(address _icoManager) {
        require(_icoManager != 0x0);

        exotownToken = new ExoTownToken(this);
        icoManager = _icoManager;
    }

    
    
    
    
    
    
    

    function init(
        address _founder,
        address _dev,
        address _pr,
        address _team,
        address _buyback,
        address _mediator
    ) onlyManager {
        require(currentState == State.Pause);
        require(_founder != 0x0);
        require(_dev != 0x0);
        require(_pr != 0x0);
        require(_team != 0x0);
        require(_buyback != 0x0);
        require(_mediator != 0x0);

        founderWallet = _founder;
        developmentWallet = _dev;
        marketingWallet = _pr;
        teamWallet = _team;
        buyBack = _buyback;
        mediatorWallet = _mediator;

        currentState = State.Running;

        exotownToken.emitTokens(icoManager, 0);
    }

    
    
    function setState(State _newState) public onlyManager {
        currentState = _newState;
    }

    
    
    function setNewManager(address _newIcoManager) onlyManager {
        require(_newIcoManager != 0x0);
        icoManager = _newIcoManager;
    }

    
    
    function setBountyCampaign(address _bountyOwner) onlyManager {
        require(_bountyOwner != 0x0);
        bountyOwner = _bountyOwner;
    }

    
    
    function setNewMediator(address _mediator) onlyManager {
        require(_mediator != 0x0);
        mediatorWallet = _mediator;
    }


    
    
    function buyTokens(address _buyer) private {
        require(_buyer != 0x0);
        require(msg.value > 0);

        uint tokensToEmit = msg.value * getPrice();
        uint volumeBonusPercent = volumeBonus(msg.value);

        if (volumeBonusPercent > 0) {
            tokensToEmit = mul(tokensToEmit, 100 + volumeBonusPercent) / 100;
        }

        uint stageSupplyLimit = getStageSupplyLimit();
        uint stageSoldTokens = getStageSoldTokens();

        require(add(stageSoldTokens, tokensToEmit) <= stageSupplyLimit);

        exotownToken.emitTokens(_buyer, tokensToEmit);

        
        addStageTokensSold(tokensToEmit);
        addStageEtherRaised(msg.value);

        distributeEtherByStage();

    }

    
    function giftToken(address _to) public payable onIco {
        buyTokens(_to);
    }

    
    function () payable onIco {
        buyTokens(msg.sender);
    }

    function distributeEtherByStage() private {
        uint _balance = this.balance;
        uint _balance_div = _balance / 100;

        uint _devAmount = _balance_div * 65;
        uint _prAmount = _balance_div * 25;

        uint total = _devAmount + _prAmount;
        if (total > 0) {
            
            

            uint _mediatorAmount = _devAmount / 100;
            mediatorWallet.transfer(_mediatorAmount);

            developmentWallet.transfer(_devAmount - _mediatorAmount);
            marketingWallet.transfer(_prAmount);
            teamWallet.transfer(_balance - _devAmount - _prAmount);
        }
    }


    
    function withdrawEther(uint _value) onlyManager {
        require(_value > 0);
        require(_value * 1000000000000000 <= this.balance);
        
        icoManager.transfer(_value * 1000000000000000); 
    }

    
    function sendTokensToBountyOwner() onlyManager whenInitialized hasBountyCampaign afterPublicSale {
        require(!sentTokensToBountyOwner);

        
        uint bountyTokens = getTokensSold() / 40; 

        exotownToken.emitTokens(bountyOwner, bountyTokens);

        sentTokensToBountyOwner = true;
    }

    
    function sendTokensToFounders() onlyManager whenInitialized afterPublicSale {
        require(!sentTokensToFounders);
        require(now >= foundersTokensUnlock);

        
        uint founderReward = getTokensSold() / 10; 

        exotownToken.emitTokens(founderWallet, founderReward);

        sentTokensToFounders = true;
    }

    
    function burnTokens(uint _amount) afterPublicSale {
        exotownToken.burnTokens(buyBack, _amount);
    }
}