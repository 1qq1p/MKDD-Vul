pragma solidity ^0.4.24;










contract NETCrowdsale is Owned {
   using SafeMath for uint;

    address vaulted;

    uint restrictedPercent;

    address restricted;

    NeuralTradeToken public token = new NeuralTradeToken();

    uint start;

    uint period = 140;

    uint hardcap;

    uint rate;

    uint minPurchase;

    uint earlyBirdBonus;

    constructor() public payable {
        owner = msg.sender;
        vaulted = 0xbffCFc20D314333B9Ff92fb157A6bd6dA4474A2E;
        restricted = 0x9c3730239B2AB9B9575F093dF593867041f777dF;
        restrictedPercent = 50;
        rate = 100;
        start = 1550448000;
        period = 140;
        minPurchase = 0.1 ether;
        earlyBirdBonus = 1 ether;
    }

    modifier saleIsOn() {
    	require(now > start && now < start + period * 1 days);
    	_;
    }

    modifier purchaseAllowed() {
        require(msg.value >= minPurchase);
        _;
    }

    function createTokens() saleIsOn purchaseAllowed public payable {
        vaulted.transfer(msg.value);
        uint tokens = rate.mul(msg.value).div(1 ether);
        uint bonusTokens = 0;
        if(now < start + (period * 1 days).div(10) && msg.value >= earlyBirdBonus) {
          bonusTokens = tokens.div(1);
        } else if(now < start + (period * 1 days).div(10).mul(2)) {
          bonusTokens = tokens.div(2);
        } else if(now >= start + (period * 1 days).div(10).mul(2) && now < start + (period * 1 days).div(10).mul(4)) {
          bonusTokens = tokens.div(4);
        } else if(now >= start + (period * 1 days).div(10).mul(4) && now < start + (period * 1 days).div(10).mul(8)) {
          bonusTokens = tokens.div(5);
        }
        uint tokensWithBonus = tokens.add(bonusTokens);
        token.transfer(msg.sender, tokensWithBonus);

        uint restrictedTokens = tokens.mul(restrictedPercent).div(100 - restrictedPercent);
        token.transfer(restricted, restrictedTokens);

        if(msg.data.length == 20) {
          address referer = bytesToAddress(bytes(msg.data));
          require(referer != msg.sender);
          uint refererTokens = tokens.mul(10).div(100);
          token.transfer(referer, refererTokens);
        }
    }

    function bytesToAddress(bytes source) internal pure returns(address) {
        uint result;
        uint mul = 1;
        for(uint i = 20; i > 0; i--) {
          result += uint8(source[i-1])*mul;
          mul = mul*256;
        }
        return address(result);
    }

    function() external payable {
        createTokens();
    }

}