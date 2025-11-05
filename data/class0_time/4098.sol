pragma solidity ^0.4.18;
 





contract Crowdsale is PIONEER {
    
    using SafeMath for uint;
    
    address multisig;
 
    uint restrictedPercent;
 
    address restricted;
 
    PIONEER public token = new PIONEER();
 
    uint start;
    
    uint period;
 
    uint hardcap;
 
    uint rate;
 
    function Crowdsale() {
	multisig = 0x0C12c4a7A690663813612924377262b7A957Eb23;
	restricted = 0x0C12c4a7A690663813612924377262b7A957Eb23;
	restrictedPercent = 50;
	rate = 550 * (10 ** 8);
	start = 1508743500; 

	period = 28;
        hardcap = 100000 * (10 ** 18);
    }
 
    modifier saleIsOn() {
    	require(now > start && now < start + period * 1 days);
    	_;
    }
	
    modifier isUnderHardCap() {
        require(multisig.balance <= hardcap);
        _;
    }
 
    function finishMinting() public onlyOwner {
	uint issuedTokenSupply = token.totalSupply();
	uint restrictedTokens = issuedTokenSupply.mul(restrictedPercent).div(100 - restrictedPercent);
	token.mint(restricted, restrictedTokens);
    }
 
   function createTokens() isUnderHardCap saleIsOn payable {
     multisig.transfer(msg.value);
        uint tokens = rate.mul(msg.value).div(1 ether);
        uint bonusTokens = 0;
        if(now < (start + 1 days)) {
          bonusTokens = 200;
        } else if(now < (start + 1 days) + (period * 1 days).div(4)) {
          bonusTokens = 150;
        } else if(now >= (start + 1 days) + (period * 1 days).div(4) && now < (start + 1 days) + (period * 1 days).div(4).mul(2)) {
          bonusTokens = 100;
        } else if(now >= (start + 1 days) + (period * 1 days).div(4).mul(2) && now < (start + 1 days) + (period * 1 days).div(4).mul(3)) {
          bonusTokens = 50;
        }
        tokens += bonusTokens;
        token.mint(msg.sender, tokens);
    }
  
 
    function() external payable {
        createTokens();
    }
    
}