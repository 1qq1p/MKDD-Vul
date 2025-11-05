pragma solidity 0.4.24;

contract UbricoinCrowdsale is FinalizeAgent,WhitelistedCrowdsale {
    using SafeMath for uint256;
    address public beneficiary;
    uint256 public fundingGoal;
    uint256 public amountRaised;
    uint256 public deadline;
       
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;
    uint256 public investorCount = 0;
    
    bool public requiredSignedAddress;
    bool public requireCustomerId;
    

    bool public paused = false;

    
    event GoalReached(address recipient, uint256 totalAmountRaised);
    event FundTransfer(address backer, uint256 amount, bool isContribution);
    
    
    event Invested(address investor, uint256 weiAmount, uint256 tokenAmount, uint256 customerId);

  
    event InvestmentPolicyChanged(bool requireCustomerId, bool requiredSignedAddress, address signerAddress);
    event Pause();
    event Unpause();
 
     
 
    modifier afterDeadline() { if (now >= deadline) _; }
    

    




     
    function invest(address ) public payable {
    if(requireCustomerId) revert(); 
    if(requiredSignedAddress) revert(); 
   
  }
     
    function investWithCustomerId(address , uint256 customerId) public payable {
    if(requiredSignedAddress) revert(); 
    if(customerId == 0)revert();  

  }
  
    function buyWithCustomerId(uint256 customerId) public payable {
    investWithCustomerId(msg.sender, customerId);
  }
     
     
    function checkGoalReached() afterDeadline public {
        if (amountRaised >= fundingGoal){
            fundingGoalReached = true;
            emit GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }

   

    






    function safeWithdrawal() afterDeadline public {
        if (!fundingGoalReached) {
            uint256 amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                emit FundTransfer(beneficiary,amountRaised,false);
                } else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }

        if  (fundingGoalReached && beneficiary == msg.sender) {
            if (beneficiary.send(amountRaised)) {
               emit FundTransfer(beneficiary,amountRaised,false);
            } else {
                
                fundingGoalReached = false;
            }
        }
    }
    
     


  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  


  modifier whenPaused {
    require(paused);
    _;
  }

  


  function pause() onlyOwner whenNotPaused public returns (bool) {
    paused = true;
    emit Pause();
    return true;
  }

  


  function unpause() onlyOwner whenPaused public returns (bool) {
    paused = false;
    emit Unpause();
    return true;
  }

}