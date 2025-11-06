pragma solidity ^0.4.18;







contract EBSCSale is Pausable {

    using SafeMath for uint256;

    
    address public beneficiary;

    
    uint public fundingGoal;
    uint public fundingCap;
    uint public minContribution;
    bool public fundingGoalReached = false;
    bool public fundingCapReached = false;
    bool public saleClosed = false;

    
    uint public startTime;
    uint public endTime;

    
    uint public amountRaised;

    
    uint public refundAmount;

    
    uint public rate = 6000;
    uint public constant LOW_RANGE_RATE = 500;
    uint public constant HIGH_RANGE_RATE = 20000;

    
    bool private rentrancy_lock = false;

    
    EBSCToken public tokenReward;

    
    mapping(address => uint256) public balanceOf;

    
    event GoalReached(address _beneficiary, uint _amountRaised);
    event CapReached(address _beneficiary, uint _amountRaised);
    event FundTransfer(address _backer, uint _amount, bool _isContribution);

    
    modifier beforeDeadline()   { require (currentTime() < endTime); _; }
    modifier afterDeadline()    { require (currentTime() >= endTime); _; }
    modifier afterStartTime()    { require (currentTime() >= startTime); _; }

    modifier saleNotClosed()    { require (!saleClosed); _; }

    modifier nonReentrant() {
        require(!rentrancy_lock);
        rentrancy_lock = true;
        _;
        rentrancy_lock = false;
    }

    











    function EBSCSale(
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint fundingCapInEthers,
        uint minimumContributionInWei,
        uint start,
        uint end,
        uint rateEBSCToEther,
        address addressOfTokenUsedAsReward
    ) public {
        require(ifSuccessfulSendTo != address(0) && ifSuccessfulSendTo != address(this));
        require(addressOfTokenUsedAsReward != address(0) && addressOfTokenUsedAsReward != address(this));
        require(fundingGoalInEthers <= fundingCapInEthers);
        require(end > 0);
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers * 1 ether;
        fundingCap = fundingCapInEthers * 1 ether;
        minContribution = minimumContributionInWei;
        startTime = start;
        endTime = end; 
        setRate(rateEBSCToEther);
        tokenReward = EBSCToken(addressOfTokenUsedAsReward);
    }

    









    function () public payable whenNotPaused beforeDeadline afterStartTime saleNotClosed nonReentrant {
        require(msg.value >= minContribution);

        
        uint amount = msg.value;
        uint currentBalance = balanceOf[msg.sender];
        balanceOf[msg.sender] = currentBalance.add(amount);
        amountRaised = amountRaised.add(amount);

        
        
        
        uint numTokens = amount.mul(rate);

        
        if (tokenReward.transferFrom(tokenReward.owner(), msg.sender, numTokens)) {
            FundTransfer(msg.sender, amount, true);
            
            
            checkFundingGoal();
            checkFundingCap();
        }
        else {
            revert();
        }
    }

    


    function terminate() external onlyOwner {
        saleClosed = true;
    }

    




    function setRate(uint _rate) public onlyOwner {
        require(_rate >= LOW_RANGE_RATE && _rate <= HIGH_RANGE_RATE);
        rate = _rate;
    }

    










    function ownerAllocateTokens(address _to, uint amountWei, uint amountMiniEbsc) external
            onlyOwner nonReentrant
    {
        if (!tokenReward.transferFrom(tokenReward.owner(), _to, amountMiniEbsc)) {
            revert();
        }
        balanceOf[_to] = balanceOf[_to].add(amountWei);
        amountRaised = amountRaised.add(amountWei);
        FundTransfer(_to, amountWei, true);
        checkFundingGoal();
        checkFundingCap();
    }

    





    function ownerSafeWithdrawal() external onlyOwner nonReentrant {
        require(fundingGoalReached);
        uint balanceToSend = this.balance;
        beneficiary.transfer(balanceToSend);
        FundTransfer(beneficiary, balanceToSend, false);
    }

    






    function ownerUnlockFund() external afterDeadline onlyOwner {
        fundingGoalReached = false;
    }

    




    function safeWithdrawal() external afterDeadline nonReentrant {
        if (!fundingGoalReached) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                msg.sender.transfer(amount);
                FundTransfer(msg.sender, amount, false);
                refundAmount = refundAmount.add(amount);
            }
        }
    }

    



    function checkFundingGoal() internal {
        if (!fundingGoalReached) {
            if (amountRaised >= fundingGoal) {
                fundingGoalReached = true;
                GoalReached(beneficiary, amountRaised);
            }
        }
    }

    



    function checkFundingCap() internal {
        if (!fundingCapReached) {
            if (amountRaised >= fundingCap) {
                fundingCapReached = true;
                saleClosed = true;
                CapReached(beneficiary, amountRaised);
            }
        }
    }

    



    function currentTime() public constant returns (uint _currentTime) {
        return now;
    }


    





    function convertToMiniEbsc(uint amount) internal constant returns (uint) {
        return amount * (10 ** uint(tokenReward.decimals()));
    }

    


    function changeStartTime(uint256 _startTime) external onlyOwner {startTime = _startTime;}
    function changeEndTime(uint256 _endTime) external onlyOwner {endTime = _endTime;}
}