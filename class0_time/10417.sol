pragma solidity ^0.4.15;


contract CashPokerProPreICO is Ownable, Pausable {
    using SafeMath for uint;

    
    address public tokenWallet = 0x774d91ac35f4e2f94f0e821a03c6eaff8ad4c138;
	
    uint public tokensSold;

    uint public weiRaised;

    mapping (address => uint256) public purchasedTokens;
     
    uint public investorCount;

    Token public token = Token(0xA8F93FAee440644F89059a2c88bdC9BF3Be5e2ea);

    uint public constant minInvest = 0.01 ether;

    uint public constant tokensLimit = 8000000 * 1 ether;

    
    uint256 public startTime = 1503770400; 
    
    uint256 public endTime = 1504893600; 

    uint public price = 0.00017 * 1 ether;

    






    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    
    function() payable {
        buyTokens(msg.sender);
    }

    
    function buyTokens(address beneficiary) whenNotPaused payable {
        require(startTime <= now && now <= endTime);

        uint weiAmount = msg.value;

        require(weiAmount >= minInvest);

        uint tokenAmountEnable = tokensLimit.sub(tokensSold);

        require(tokenAmountEnable > 0);

        uint tokenAmount = weiAmount / price * 1 ether;

        if (tokenAmount > tokenAmountEnable) {
            tokenAmount = tokenAmountEnable;
            weiAmount = tokenAmount * price / 1 ether;
            msg.sender.transfer(msg.value - weiAmount);
        }

        if (purchasedTokens[beneficiary] == 0) investorCount++;
        
        purchasedTokens[beneficiary] = purchasedTokens[beneficiary].add(tokenAmount);

        weiRaised = weiRaised.add(weiAmount);

        require(token.transferFrom(tokenWallet, beneficiary, tokenAmount));

        tokensSold = tokensSold.add(tokenAmount);

        TokenPurchase(msg.sender, beneficiary, weiAmount, tokenAmount);
    }

    function withdrawal(address to) onlyOwner {
        to.transfer(this.balance);
    }

    function transfer(address to, uint amount) onlyOwner {
        uint tokenAmountEnable = tokensLimit.sub(tokensSold);

        if (amount > tokenAmountEnable) amount = tokenAmountEnable;

        require(token.transferFrom(tokenWallet, to, amount));

        tokensSold = tokensSold.add(amount);
    }
}