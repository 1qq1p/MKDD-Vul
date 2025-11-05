pragma solidity ^0.4.18;





contract Crowdsale is Ownable {
    
    using SafeMath for uint;
    
    address multisig;

    uint restrictedPercent;

    address restricted;

    TokenTokenCoin public token = new TokenTokenCoin();

    uint start;
    
    uint period;

    uint hardcap;

    uint rate;

    function Crowdsale() public {
        multisig = 0x270A26Ef971a68B9b77d3104c328932ddBd8366a;
        restricted = 0x188a11a676B5D3D4f39b865F8D88d27CdFa2Af59;
        restrictedPercent = 20;
        rate = 100000000000000000000;
        start = 1518220800;
        period = 60;
        hardcap = 1000000000000000000000000;
                  
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
        token.finishMinting();
    }

    function createTokens() public isUnderHardCap saleIsOn payable {
        multisig.transfer(msg.value);
        uint tokens = rate.mul(msg.value).div(1 ether);
        token.mint(msg.sender, tokens);
    }

    function() external payable {
        createTokens();
    }
    
}