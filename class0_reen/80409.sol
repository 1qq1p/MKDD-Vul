pragma solidity ^0.4.15;

library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        if (a != 0 && c / a != b) revert();
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        
        uint256 c = a / b;
        
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        if (b > a) revert();
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        if (c < a) revert();
        return c;
    }
}

contract IRBToken is StandardToken, Ownable {
    using SafeMath for uint256;

    


    string public constant name = "IRB Tokens";

    string public constant symbol = "IRB";

    uint8 public decimals = 18;

    


    uint256 public constant crowdsaleTokens = 489580 * 10 ** 21;

    


    uint256 public constant preCrowdsaleTokens = 10420 * 10 ** 21;

    
    
    address public constant preCrowdsaleTokensWallet = 0x0CD95a59fAd089c4EBCCEB54f335eC8f61Caa80e;
    
    address public constant crowdsaleTokensWallet = 0x48545E41696Dc51020C35cA8C36b678101a98437;

    



    address public preCrowdsaleContractAddress;

    



    address public crowdsaleContractAddress;

    


    bool isPreFinished = false;

    


    bool isFinished = false;

    


    modifier onlyPreCrowdsaleContract() {
        require(msg.sender == preCrowdsaleContractAddress);
        _;
    }

    


    modifier onlyCrowdsaleContract() {
        require(msg.sender == crowdsaleContractAddress);
        _;
    }

    



    event TokensBurnt(uint256 tokens);

    



    event Live(uint256 supply);

    


    function IRBToken() {
        
        balances[preCrowdsaleTokensWallet] = balanceOf(preCrowdsaleTokensWallet).add(preCrowdsaleTokens);
        Transfer(address(0), preCrowdsaleTokensWallet, preCrowdsaleTokens);

        
        balances[crowdsaleTokensWallet] = balanceOf(crowdsaleTokensWallet).add(crowdsaleTokens);
        Transfer(address(0), crowdsaleTokensWallet, crowdsaleTokens);

        
        totalSupply = crowdsaleTokens.add(preCrowdsaleTokens);
    }

    



    function setPreCrowdsaleAddress(address _preCrowdsaleAddress) onlyOwner external {
        require(_preCrowdsaleAddress != address(0));
        preCrowdsaleContractAddress = _preCrowdsaleAddress;

        
        uint256 balance = balanceOf(preCrowdsaleTokensWallet);
        allowed[preCrowdsaleTokensWallet][preCrowdsaleContractAddress] = balance;
        Approval(preCrowdsaleTokensWallet, preCrowdsaleContractAddress, balance);
    }

    



    function setCrowdsaleAddress(address _crowdsaleAddress) onlyOwner external {
        require(isPreFinished);
        require(_crowdsaleAddress != address(0));
        crowdsaleContractAddress = _crowdsaleAddress;

        
        uint256 balance = balanceOf(crowdsaleTokensWallet);
        allowed[crowdsaleTokensWallet][crowdsaleContractAddress] = balance;
        Approval(crowdsaleTokensWallet, crowdsaleContractAddress, balance);
    }

    


    function endPreTokensale() onlyPreCrowdsaleContract external {
        require(!isPreFinished);
        uint256 preCrowdsaleLeftovers = balanceOf(preCrowdsaleTokensWallet);

        if (preCrowdsaleLeftovers > 0) {
            balances[preCrowdsaleTokensWallet] = 0;
            balances[crowdsaleTokensWallet] = balances[crowdsaleTokensWallet].add(preCrowdsaleLeftovers);
            Transfer(preCrowdsaleTokensWallet, crowdsaleTokensWallet, preCrowdsaleLeftovers);
        }

        isPreFinished = true;
    }

    


    function endTokensale() onlyCrowdsaleContract external {
        require(!isFinished);
        uint256 crowdsaleLeftovers = balanceOf(crowdsaleTokensWallet);

        if (crowdsaleLeftovers > 0) {
            totalSupply = totalSupply.sub(crowdsaleLeftovers);

            balances[crowdsaleTokensWallet] = 0;
            Transfer(crowdsaleTokensWallet, address(0), crowdsaleLeftovers);
            TokensBurnt(crowdsaleLeftovers);
        }

        isFinished = true;
        Live(totalSupply);
    }
}