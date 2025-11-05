pragma solidity ^0.4.24;

interface token {
    function transfer(address receiver, uint amount);
    function burn(uint256 _value) returns (bool);
    function balanceOf(address _address) returns (uint256);
}
contract Crowdsale is owned, SafeMath {
    address public beneficiary;
    uint public fundingGoal;
    uint public amountRaised;  
    
    uint public deadline; 
    uint public rate; 
    uint public tokenDecimals;
    token public tokenReward; 
    uint public tokensSold = 0;  
    
    uint public start; 
    mapping(address => uint256) public balanceOf;  
    
    bool crowdsaleClosed = false; 

    event GoalReached(address beneficiary, uint capital);
    event FundTransfer(address backer, uint amount, bool isContribution);

    




    function Crowdsale( ) {
        beneficiary = 0xE579891b98a3f58E26c4B2edB54E22250899363c;
        rate = 40000; 
        tokenDecimals=8;
        fundingGoal = 2500000000 * (10 ** tokenDecimals); 
        start = 1536537600; 
        deadline =1539129600; 
        tokenReward = token(0x19335137283563C9531062EDD04ddf19d42097bd); 
    }    

    




     


    function () payable {
        uint amount = msg.value;  
        uint numTokens; 
        numTokens = getNumTokens(amount);   
        require(numTokens>0 && !crowdsaleClosed && now > start && now < deadline);
        balanceOf[msg.sender] = safeAdd(balanceOf[msg.sender], amount);
        amountRaised = safeAdd(amountRaised, amount); 
        tokensSold += numTokens; 
        tokenReward.transfer(msg.sender, numTokens); 
        beneficiary.transfer(amount);               
        FundTransfer(msg.sender, amount, true);
    }
    


    function getNumTokens(uint _value) internal returns(uint numTokens) {
        require(_value>=10000000000000000 * 1 wei); 
        numTokens = safeMul(_value,rate)/(10 ** tokenDecimals); 
        return numTokens;
    }

    function changeBeneficiary(address newBeneficiary) onlyOwner {
        beneficiary = newBeneficiary;
    }

    modifier afterDeadline() { if (now >= deadline) _; }

    




    function checkGoalReached() afterDeadline {
        require(msg.sender == owner); 
        if (tokensSold >=fundingGoal){
            GoalReached(beneficiary, amountRaised);
        }
        tokenReward.burn(tokenReward.balanceOf(this)); 
        crowdsaleClosed = true; 
    }



}