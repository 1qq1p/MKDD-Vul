pragma solidity ^0.4.11;

library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns(uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Crowdsale is Pausable {
    using SafeMath for uint;

    Token public token;
    address public beneficiary = 0xe97be260bB25d84860592524E5086C07c3cb3C0c;        

    uint public collectedWei;
    uint public refundedWei;
    uint public tokensSold;

    uint public tokensForSale = 2000000 * 1 ether;                                 
    uint public priceTokenWei = 1 ether / 2000;
    uint public priceTokenWeiPreICO = 333333333333333; 

    uint public startTime = 1513299600;                                             
    uint public endTime = 1517360399;                                               
    bool public crowdsaleFinished = false;
    bool public refundOpen = false;

    mapping(address => uint256) saleBalances; 

    event NewContribution(address indexed holder, uint256 tokenAmount, uint256 etherAmount);
    event Refunded(address indexed holder, uint256 etherAmount);
    event Withdraw();

    function Crowdsale() {
        token = new Token();
    }

    function() payable {
        purchase();
    }
    
    
    
    
    function purchase() whenNotPaused payable {
        require(!crowdsaleFinished);
        require(now >= startTime && now < endTime);
        require(tokensSold < tokensForSale);
        require(msg.value >= 0.001 * 1 ether && msg.value <= 100 * 1 ether);

        uint sum = msg.value;
        uint amount = sum.div(priceTokenWeiPreICO).mul(1 ether);
        uint retSum = 0;
        
        if(tokensSold.add(amount) > tokensForSale) {
            uint retAmount = tokensSold.add(amount).sub(tokensForSale);
            retSum = retAmount.mul(priceTokenWeiPreICO).div(1 ether);

            amount = amount.sub(retAmount);
            sum = sum.sub(retSum);
        }

        tokensSold = tokensSold.add(amount);
        collectedWei = collectedWei.add(sum);
        saleBalances[msg.sender] = saleBalances[msg.sender].add(sum);

        token.transfer(msg.sender, amount);

        if(retSum > 0) {
            msg.sender.transfer(retSum);
        }

        NewContribution(msg.sender, amount, sum);
    }

    
    function withdraw(bool refund) onlyOwner {
        require(!crowdsaleFinished);

        if(token.balanceOf(this) > 0) {
            token.transfer(beneficiary, token.balanceOf(this));
        }

        if(refund && tokensSold < tokensForSale) {
            refundOpen = true;
        }
        else {
            beneficiary.transfer(this.balance);
        }
        
        token.transferOwnership(beneficiary);
        crowdsaleFinished = true;

        Withdraw();
    }
    
    function refund() {
        require(crowdsaleFinished);
        require(refundOpen);
        require(saleBalances[msg.sender] > 0);

        uint sum = saleBalances[msg.sender];

        saleBalances[msg.sender] = 0;
        refundedWei = refundedWei.add(sum);

        msg.sender.transfer(sum);
        
        Refunded(msg.sender, sum);
    }
}