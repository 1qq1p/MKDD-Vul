pragma solidity ^0.4.19;


   
   
   
   
library SafeMath {
    function mul(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

function div(uint256 a, uint256 b) internal returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
    }
 
function sub(uint256 a, uint256 b) internal returns (uint256) {
    assert(b <= a);
    return a - b;
    }

function add(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
    }
} 

contract Crowdsale is Ownable {
    using SafeMath for uint256;
    
    
    MintableToken public token;
    
    
    uint256 public deadline;
    
    
    address public wallet;
    
    
    uint256 public rate;
    
    
    uint256 public weiRaised;
    
    
    uint256 public tokensSold;
    
    
    
    
    
    
    
    
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    
    
    function Crowdsale(MintableToken tokenContract, uint256 durationInWeeks, uint256 _rate, address _wallet) {
        
        require(_rate > 0);
        require(_wallet != 0x0);
        
        
        token = tokenContract;
        
        deadline = now + durationInWeeks * 1 weeks;
        rate = _rate;
        wallet = _wallet;
        
        
        
        
    }
    
    
    function setNewTokenOwner(address newOwner) onlyOwner {
        token.transferOwnership(newOwner);
    }
    
    
    
    function createTokenContract() internal returns (MintableToken) {
        return new MintableToken();
    }
    
    
    
    function () payable {
        buyTokens(msg.sender);
    }
    
    
    function buyTokens(address beneficiary) payable {
        require(beneficiary != 0x0);
        require(validPurchase());
        
        uint256 weiAmount = msg.value;
        uint256 updatedweiRaised = weiRaised.add(weiAmount);
        
        
        uint256 tokens = weiAmount.mul(rate);
        
        
        require ( tokens <= token.balanceOf(this) );
        
        
        weiRaised = updatedweiRaised;
        
        
        token.transfer(beneficiary, tokens);
        
        tokensSold = tokensSold.add(tokens);
        
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
        
        forwardFunds();
    }
    
    
    
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }
    
    
    function validPurchase() internal constant returns (bool) {
        uint256 current = block.number;
        bool withinPeriod = now <= deadline;
        bool nonZeroPurchase = msg.value != 0;
        
        return withinPeriod && nonZeroPurchase;
    }
    
    
    function hasEnded() public constant returns (bool) {
        return ( now > deadline);
        
        
    }
    
    function tokenResend() onlyOwner {
        
        
        
        token.transfer(owner, token.balanceOf(this));
    }
    
}