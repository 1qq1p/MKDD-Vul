pragma solidity ^0.4.4;

contract GWTCrowdsale is Ownable {
    using SafeMath for uint;

    uint public supplyLimit;         

    address ethAddress;              
    uint saleStartTimestamp;         

    uint public currentStageNumber;  
    uint currentStageStartTimestamp; 
    uint currentStageEndTimestamp;   
    uint currentStagePeriodDays;     
    uint public baseExchangeRate;    
    uint currentStageMultiplier;     

    uint constant M = 1000000000000000000;  

    uint[] _percs = [40, 30, 25, 20, 15, 10, 5, 0, 0];  
    uint[] _days  = [42, 1, 27, 1, 7, 7, 7, 14, 0];      

    
    uint PrivateSaleLimit = M.mul(420000000);
    uint PreSaleLimit = M.mul(1300000000);
    uint TokenSaleLimit = M.mul(8400000000);
    uint RetailLimit = M.mul(22490000000);

    
    uint TokensaleRate = M.mul(160000);
    uint RetailRate = M.mul(16000);

    GWTToken public token = new GWTToken(); 

    
    modifier isActive() {
        require(isInActiveStage());
        _;
    }

    function isInActiveStage() private returns(bool) {
        if (currentStageNumber == 8) return true;
        if (now >= currentStageStartTimestamp && now <= currentStageEndTimestamp){
            return true;
        }else if (now < currentStageStartTimestamp) {
            return false;
        }else if (now > currentStageEndTimestamp){
            if (currentStageNumber == 0 || currentStageNumber == 2 || currentStageNumber == 7) return false;
            switchPeriod();
            
            
            
            return true;
        }
        
        return false;
    }

    
    function switchPeriod() private onlyOwner {
        if (currentStageNumber == 8) return;

        currentStageNumber++;
        currentStageStartTimestamp = currentStageEndTimestamp; 
        currentStagePeriodDays = _days[currentStageNumber];
        currentStageEndTimestamp = currentStageStartTimestamp + currentStagePeriodDays * 1 days;
        currentStageMultiplier = _percs[currentStageNumber];

        if(currentStageNumber == 0 ){
            supplyLimit = PrivateSaleLimit;
        } else if(currentStageNumber < 3){
            supplyLimit = PreSaleLimit;
        } else if(currentStageNumber < 8){
            supplyLimit = TokenSaleLimit;
        } else {
            
            baseExchangeRate = RetailRate;
            supplyLimit = RetailLimit;
        }
    }

    function setStage(uint _index) public onlyOwner {
        require(_index >= 0 && _index < 9);
        
        if (_index == 0) return startPrivateSale();
        currentStageNumber = _index - 1;
        currentStageEndTimestamp = now;
        switchPeriod();
    }

    
    function setRate(uint _rate) public onlyOwner {
        baseExchangeRate = _rate;
    }

    
    function setBonus(uint _bonus) public onlyOwner {
        currentStageMultiplier = _bonus;
    }

    function setTokenOwner(address _newTokenOwner) public onlyOwner {
        token.transferOwnership(_newTokenOwner);
    }

    
    function setPeriodLength(uint _length) public onlyOwner {
        
        currentStagePeriodDays = _length;
        currentStageEndTimestamp = currentStageStartTimestamp + currentStagePeriodDays * 1 days;
    }

    
    function modifySupplyLimit(uint _new) public onlyOwner {
        if (_new >= token.totalSupply()){
            supplyLimit = _new;
        }
    }

    
    function mintFor(address _to, uint _val) public onlyOwner isActive payable {
        require(token.totalSupply() + _val <= supplyLimit);
        token.mint(_to, _val);
    }

    
    
    function closeMinting() public onlyOwner {
        token.finishMinting();
    }

    
    function startPrivateSale() public onlyOwner {
        currentStageNumber = 0;
        currentStageStartTimestamp = now;
        currentStagePeriodDays = _days[0];
        currentStageMultiplier = _percs[0];
        supplyLimit = PrivateSaleLimit;
        currentStageEndTimestamp = currentStageStartTimestamp + currentStagePeriodDays * 1 days;
        baseExchangeRate = TokensaleRate;
    }

    function startPreSale() public onlyOwner {
        currentStageNumber = 0;
        currentStageEndTimestamp = now;
        switchPeriod();
    }

    function startTokenSale() public onlyOwner {
        currentStageNumber = 2;
        currentStageEndTimestamp = now;
        switchPeriod();
    }

    function endTokenSale() public onlyOwner {
        currentStageNumber = 7;
        currentStageEndTimestamp = now;
        switchPeriod();
    }

    
    
    function GWTCrowdsale() public {
        
        ethAddress = 0xB93B2be636e39340f074F0c7823427557941Be42;  
        
        saleStartTimestamp = now;                                       
        startPrivateSale();
    }

    function changeEthAddress(address _newAddress) public onlyOwner {
        ethAddress = _newAddress;
    }

    
    function createTokens() public isActive payable {
        uint tokens = baseExchangeRate.mul(msg.value).div(1 ether); 

        if (currentStageMultiplier > 0 && currentStageEndTimestamp > now) {            
            tokens = tokens + tokens.div(100).mul(currentStageMultiplier);
        }
        
        require(token.totalSupply() + tokens <= supplyLimit);
        ethAddress.transfer(msg.value);   
        token.mint(msg.sender, tokens); 
    }

    
    function() external payable {
        createTokens(); 
    }

}