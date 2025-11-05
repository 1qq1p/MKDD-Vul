pragma solidity ^0.4.11;





contract SaleExtendedBCO {
    address public beneficiary;
    uint public startline;
    uint public deadline;
    uint public price;
    uint public amountRaised;
    uint public incomingTokensTransactions;

    mapping(address => uint) public actualGotETH;
    BCOExtendedToken public tokenReward;

    event TokenFallback( address indexed from,
                         uint256 value);

    modifier onlyOwner() {
        if(msg.sender != beneficiary) revert();
        _;
    }

    modifier whenCrowdsaleIsFinished() {
        if(now < deadline) revert();
        _;
    }

    modifier whenRefundAvailable() {
        if(tokenReward.balanceOf(address(this)) <= 0) revert();
        _;
    }

    function SaleExtendedBCO(
        uint start,
        uint end,
        uint costOfEachToken,
        BCOExtendedToken addressOfTokenUsedAsReward
    ) {
        beneficiary = msg.sender;
        startline = start;
        deadline = end;
        price = costOfEachToken;
        tokenReward = BCOExtendedToken(addressOfTokenUsedAsReward);
    }

    function () payable {
        if (now <= startline) revert();
        if (now >= deadline) revert();

        uint amount = msg.value;
        if (amount < price) revert();

        amountRaised += amount;

        uint tokensToSend = amount / price;

        actualGotETH[msg.sender] += amount;

        tokenReward.transfer(msg.sender, tokensToSend);
    }

    function transferOwnership(address newOwner) onlyOwner {
        if (newOwner != address(0)) {
            beneficiary = newOwner;
        }
    }

    function Refund() whenRefundAvailable whenCrowdsaleIsFinished {
        msg.sender.transfer(actualGotETH[msg.sender]);
    }

    function WithdrawETH(uint amount) onlyOwner {
        beneficiary.transfer(amount);
    }

    function WithdrawAllETH() onlyOwner {
        beneficiary.transfer(amountRaised);
    }

    function WithdrawTokens(uint amount) onlyOwner {
        tokenReward.transfer(beneficiary, amount);
    }

    function ChangeCost(uint costOfEachToken) onlyOwner {
        price = costOfEachToken;
    }

    function ChangeStart(uint start) onlyOwner {
        startline = start;
    }

    function ChangeEnd(uint end) onlyOwner {
        deadline = end;
    }

    
    
    function tokenFallback(address from, uint value) {
        incomingTokensTransactions += 1;
        TokenFallback(from, value);
    }
}