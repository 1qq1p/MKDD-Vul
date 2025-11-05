pragma solidity ^0.4.18;







contract Crowdsale {
    using SafeMath for uint;

    
    MintableToken public token;

    
    uint32 internal startTime;
    uint32 internal endTime;

    
    address public wallet;

    
    uint public weiRaised;

    


    uint public soldTokens;

    


    uint internal hardCap;

    






    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint value, uint amount);

    function Crowdsale(uint _startTime, uint _endTime, uint _hardCap, address _wallet) {
        require(_endTime >= _startTime);
        require(_wallet != 0x0);
        require(_hardCap > 0);

        token = createTokenContract();
        startTime = uint32(_startTime);
        endTime = uint32(_endTime);
        hardCap = _hardCap;
        wallet = _wallet;
    }

    
    
    function createTokenContract() internal returns (MintableToken) {
        return new MintableToken();
    }

    



    function getRate(uint amount) internal constant returns (uint);

    function getBaseRate() internal constant returns (uint);

    



    function getRateScale() internal constant returns (uint) {
        return 1;
    }

    
    function() payable {
        buyTokens(msg.sender, msg.value);
    }

    
    function buyTokens(address beneficiary, uint amountWei) internal {
        require(beneficiary != 0x0);

        
        uint totalSupply = token.totalSupply();

        
        uint actualRate = getRate(amountWei);
        uint rateScale = getRateScale();

        require(validPurchase(amountWei, actualRate, totalSupply));

        
        uint tokens = amountWei.mul(actualRate).div(rateScale);

        
        weiRaised = weiRaised.add(amountWei);
        soldTokens = soldTokens.add(tokens);

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, amountWei, tokens);

        forwardFunds(amountWei);
    }

    
    
    function forwardFunds(uint amountWei) internal {
        wallet.transfer(amountWei);
    }

    



    function validPurchase(uint _amountWei, uint _actualRate, uint _totalSupply) internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = _amountWei != 0;
        bool hardCapNotReached = _totalSupply <= hardCap;

        return withinPeriod && nonZeroPurchase && hardCapNotReached;
    }

    



    function hasEnded() public constant returns (bool) {
        return now > endTime || token.totalSupply() > hardCap;
    }

    


    function hasStarted() public constant returns (bool) {
        return now >= startTime;
    }
}
