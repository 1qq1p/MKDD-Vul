pragma solidity ^ 0.4.17;


library SafeMath {
    function mul(uint a, uint b) pure internal returns(uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function sub(uint a, uint b) pure internal returns(uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) pure internal returns(uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
}







contract CrowdSale is  Pausable, Vesting {

    using SafeMath for uint;

    struct Backer {
        uint weiReceivedOne; 
        uint weiReceivedTwo;  
        uint weiReceivedMain; 
        uint tokensSent; 
        bool claimed;
        bool refunded;
    }

    address public multisig; 
    uint public ethReceivedPresaleOne; 
    uint public ethReceivedPresaleTwo; 
    uint public ethReceiveMainSale; 
    uint public totalTokensSold; 
    uint public startBlock; 
    uint public endBlock; 

    uint public minInvestment; 
    WhiteList public whiteList; 
    uint public dollarPerEtherRatio; 
    uint public returnPercentage;  
    Step public currentStep;  
    uint public minCapTokens;  

    mapping(address => Backer) public backers; 
    address[] public backersIndex;  
    uint public maxCapEth;  
    uint public maxCapTokens; 
    uint public claimCount;  
    uint public refundCount;  
    uint public totalClaimed;  
    uint public totalRefunded;  
    mapping(address => uint) public claimed; 
    mapping(address => uint) public refunded; 



    
    enum Step {
        FundingPresaleOne,  
        FundingPresaleTwo,  
        FundingMainSale,    
        Refunding           
    }


    
    modifier respectTimeFrame() {
        if ((block.number < startBlock) || (block.number > endBlock))
            revert();
        _;
    }

    
    event ReceivedETH(address indexed backer, Step indexed step, uint amount);
    event TokensClaimed(address indexed backer, uint count);
    event Refunded(address indexed backer, uint amount);



    
    
    function CrowdSale(WhiteList _whiteList, address _multisig) public {

        require(_whiteList != address(0x0));
        multisig = _multisig;
        minInvestment = 100 ether;  
        maxCapEth = 30000 ether;
        startBlock = 0; 
        endBlock = 0; 
        currentStep = Step.FundingPresaleOne;  
        whiteList = _whiteList; 
        minCapTokens = 7.5e24;  
    }


    
    
    function numberOfBackers() public view returns(uint, uint, uint, uint) {

        uint numOfBackersOne;
        uint numOfBackersTwo;
        uint numOfBackersMain;

        for (uint i = 0; i < backersIndex.length; i++) {
            Backer storage backer = backers[backersIndex[i]];
            if (backer.weiReceivedOne > 0)
                numOfBackersOne ++;
            if (backer.weiReceivedTwo > 0)
                numOfBackersTwo ++;
            if (backer.weiReceivedMain > 0)
                numOfBackersMain ++;
            }
        return ( numOfBackersOne, numOfBackersTwo, numOfBackersMain, backersIndex.length);
    }



    
    
    function setPresaleTwo() public onlyOwner() {
        currentStep = Step.FundingPresaleTwo;
        minInvestment = 10 ether;  
    }

    
    
    
    function setMainSale(uint _ratio) public onlyOwner() {

        require(_ratio > 0);
        currentStep = Step.FundingMainSale;
        dollarPerEtherRatio = _ratio;
        maxCapTokens = 50e24;
        minInvestment = 1 ether / 10;  
        totalTokensSold = (dollarPerEtherRatio * ethReceivedPresaleOne) / 48;  
        totalTokensSold += (dollarPerEtherRatio * ethReceivedPresaleTwo) / 55;  
    }


    
    function returnWebsiteData() external view returns(uint, uint, uint, uint, uint, uint, uint, uint,  bool) {

        return (startBlock, endBlock, backersIndex.length, ethReceivedPresaleOne, ethReceivedPresaleTwo, ethReceiveMainSale, maxCapTokens,   minInvestment,  stopped);
    }


    
    
    function () public payable {
        contribute(msg.sender);
    }

    
    
    function fundContract(uint _returnPercentage) external payable onlyOwner() {

        require(_returnPercentage > 0);
        require(msg.value == (ethReceivedPresaleOne.mul(_returnPercentage) / 100) + ethReceivedPresaleTwo + ethReceiveMainSale);
        returnPercentage = _returnPercentage;
        currentStep = Step.Refunding;
    }

    
    
    function start() external onlyOwner() {
        startBlock = block.number;
        endBlock = startBlock + 563472; 
    }

    
    
    
    
    function adjustDuration(uint _block) external onlyOwner() {
        
        require(_block <= 625392);  
        require(_block > block.number.sub(startBlock)); 
        endBlock = startBlock.add(_block);
    }


    
    
    

    function contribute(address _contributor) internal stopInEmergency respectTimeFrame returns(bool res) {


        require(whiteList.isWhiteListed(_contributor));  
        Backer storage backer = backers[_contributor];
        require (msg.value >= minInvestment);  

        if (backer.weiReceivedOne == 0 && backer.weiReceivedTwo == 0 && backer.weiReceivedMain == 0)
            backersIndex.push(_contributor);

        if (currentStep == Step.FundingPresaleOne) {          
            backer.weiReceivedOne = backer.weiReceivedOne.add(msg.value);
            ethReceivedPresaleOne = ethReceivedPresaleOne.add(msg.value); 
            require(ethReceivedPresaleOne <= maxCapEth);  
        }else if (currentStep == Step.FundingPresaleTwo) {           
            backer.weiReceivedTwo = backer.weiReceivedTwo.add(msg.value);
            ethReceivedPresaleTwo = ethReceivedPresaleTwo.add(msg.value);  
            require(ethReceivedPresaleOne + ethReceivedPresaleTwo <= maxCapEth);  
        }else if (currentStep == Step.FundingMainSale) {
            backer.weiReceivedMain = backer.weiReceivedMain.add(msg.value);
            ethReceiveMainSale = ethReceiveMainSale.add(msg.value);  
            uint tokensToSend = dollarPerEtherRatio.mul(msg.value) / 62;  
            totalTokensSold += tokensToSend;
            require(totalTokensSold <= maxCapTokens);  
        }
        multisig.transfer(msg.value);  

        ReceivedETH(_contributor, currentStep, msg.value); 
        return true;
    }


    
    

    function finalizeSale() external onlyOwner() {
        require(dateICOEnded == 0);
        require(currentStep == Step.FundingMainSale);
        
        
        require(block.number >= endBlock || totalTokensSold >= maxCapTokens.sub(1000));
        require(totalTokensSold >= minCapTokens);
        
        companyTokensInitial += maxCapTokens - totalTokensSold; 
        dateICOEnded = now;
        token.unlock();
    }


    
    
    
    function updateContributorAddress(address _contributorOld, address _contributorNew) public onlyOwner() {

        Backer storage backerOld = backers[_contributorOld];
        Backer storage backerNew = backers[_contributorNew];

        require(backerOld.weiReceivedOne > 0 || backerOld.weiReceivedTwo > 0 || backerOld.weiReceivedMain > 0); 
        require(backerNew.weiReceivedOne == 0 && backerNew.weiReceivedTwo == 0 && backerNew.weiReceivedMain == 0); 
        require(backerOld.claimed == false && backerOld.refunded == false);  

        
        backerOld.claimed = true;
        backerOld.refunded = true;

        
        backerNew.weiReceivedOne = backerOld.weiReceivedOne;
        backerNew.weiReceivedTwo = backerOld.weiReceivedTwo;
        backerNew.weiReceivedMain = backerOld.weiReceivedMain;
        backersIndex.push(_contributorNew);
    }

    
    
    
    function claimTokensForUser(address _backer) internal returns(bool) {        

        require(dateICOEnded > 0); 

        Backer storage backer = backers[_backer];

        require (!backer.refunded); 
        require (!backer.claimed); 
        require (backer.weiReceivedOne > 0 || backer.weiReceivedTwo > 0 || backer.weiReceivedMain > 0);   

        claimCount++;
        uint tokensToSend = (dollarPerEtherRatio * backer.weiReceivedOne) / 48;  
        tokensToSend = tokensToSend + (dollarPerEtherRatio * backer.weiReceivedTwo) / 55;  
        tokensToSend = tokensToSend + (dollarPerEtherRatio * backer.weiReceivedMain) / 62;  

        claimed[_backer] = tokensToSend;  
        backer.claimed = true;
        backer.tokensSent = tokensToSend;
        totalClaimed += tokensToSend;

        if (!token.transfer(_backer, tokensToSend))
            revert(); 

        TokensClaimed(_backer,tokensToSend);
        return true;
    }


    
    

    function claimTokens() external {
        claimTokensForUser(msg.sender);
    }


    
    
    function adminClaimTokenForUser(address _backer) external onlyOwner() {
        claimTokensForUser(_backer);
    }

    
    
    

    function refund() external {

        require(currentStep == Step.Refunding);                                                          
        require(totalTokensSold < maxCapTokens/2); 

        Backer storage backer = backers[msg.sender];

        require (!backer.claimed); 
        require (!backer.refunded); 

        uint totalEtherReceived = ((backer.weiReceivedOne * returnPercentage) / 100) + backer.weiReceivedTwo + backer.weiReceivedMain;  
        assert(totalEtherReceived > 0);

        backer.refunded = true; 
        totalRefunded += totalEtherReceived;
        refundCount ++;
        refunded[msg.sender] = totalRefunded;

        msg.sender.transfer(totalEtherReceived);  
        Refunded(msg.sender, totalEtherReceived); 
    }



    
    
    function refundNonCompliant(address _contributor) payable external onlyOwner() {
    
        Backer storage backer = backers[_contributor];

        require (!backer.claimed); 
        require (!backer.refunded); 
        backer.refunded = true; 

        uint totalEtherReceived = backer.weiReceivedOne + backer.weiReceivedTwo + backer.weiReceivedMain;

        require(msg.value == totalEtherReceived); 
        assert(totalEtherReceived > 0);

        
        ethReceivedPresaleOne -= backer.weiReceivedOne;
        ethReceivedPresaleTwo -= backer.weiReceivedTwo;
        ethReceiveMainSale -= backer.weiReceivedMain;
        
        totalRefunded += totalEtherReceived;
        refundCount ++;
        refunded[_contributor] = totalRefunded;      

        uint tokensToSend = (dollarPerEtherRatio * backer.weiReceivedOne) / 48;  
        tokensToSend = tokensToSend + (dollarPerEtherRatio * backer.weiReceivedTwo) / 55;  
        tokensToSend = tokensToSend + (dollarPerEtherRatio * backer.weiReceivedMain) / 62;  

        if(dateICOEnded == 0) {
            totalTokensSold -= tokensToSend;
        } else {
            companyTokensInitial += tokensToSend;
        }

        _contributor.transfer(totalEtherReceived);  
        Refunded(_contributor, totalEtherReceived); 
    }

    
    function drain() external onlyOwner() {
        multisig.transfer(this.balance);

    }

    
    function tokenDrain() external onlyOwner() {
    if (block.number > endBlock) {
        if (!token.transfer(multisig, token.balanceOf(this)))
                revert();
        }
    }
}





