pragma solidity 0.4.15;





library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}






contract CtdToken is UpgradableToken, PausableOnce, Withdrawable {

    using SafeMath for uint256;

    string public constant name = "Cointed Token";
    string public constant symbol = "CTD";
    
    uint8  public constant decimals = 18;

    
    address public bounty;

    
    uint256 constant internal TOTAL_LIMIT   = 650000000 * (10 ** uint256(decimals));
    
    uint256 constant internal PRE_ICO_LIMIT = 130000000 * (10 ** uint256(decimals));

    








    enum Phases {PreStart, PreIcoA, PreIcoB, MainIco, AfterIco}

    uint64 constant internal PRE_ICO_DURATION = 30 days;
    uint64 constant internal ICO_DURATION = 82 days;
    uint64 constant internal RETURN_WEI_PAUSE = 30 days;

    
    uint256 constant internal TO_SENDER_RATE   = 1000;
    uint256 constant internal TO_OWNER_RATE    =  263;
    uint256 constant internal TO_BOUNTY_RATE   =   52;
    uint256 constant internal TOTAL_RATE   =   TO_SENDER_RATE + TO_OWNER_RATE + TO_BOUNTY_RATE;
    
    uint256 constant internal TO_SENDER_RATE_A = 1150;
    uint256 constant internal TO_OWNER_RATE_A  =  304;
    uint256 constant internal TO_BOUNTY_RATE_A =   61;
    uint256 constant internal TOTAL_RATE_A   =   TO_SENDER_RATE_A + TO_OWNER_RATE_A + TO_BOUNTY_RATE_A;
    
    uint256 constant internal TO_SENDER_RATE_B = 1100;
    uint256 constant internal TO_OWNER_RATE_B  =  292;
    uint256 constant internal TO_BOUNTY_RATE_B =   58;
    uint256 constant internal TOTAL_RATE_B   =   TO_SENDER_RATE_B + TO_OWNER_RATE_B + TO_BOUNTY_RATE_B;

    
    uint256 constant internal PRE_OPENING_AWARD = 100 * (10 ** uint256(15));
    uint256 constant internal ICO_OPENING_AWARD = 200 * (10 ** uint256(15));
    uint256 constant internal ICO_CLOSING_AWARD = 500 * (10 ** uint256(15));

    struct Rates {
        uint256 toSender;
        uint256 toOwner;
        uint256 toBounty;
        uint256 total;
    }

    event NewTokens(uint256 amount);
    event NewFunds(address funder, uint256 value);
    event NewPhase(Phases phase);

    
    Phases public phase = Phases.PreStart;

    
    uint64 public preIcoOpeningTime;  
    uint64 public icoOpeningTime;     
    uint64 public closingTime;        
    uint64 public returnAllowedTime;  

    uint256 public totalProceeds;

    




    function CtdToken(uint64 _preIcoOpeningTime) payable {
        require(_preIcoOpeningTime > now);

        preIcoOpeningTime = _preIcoOpeningTime;
        icoOpeningTime = preIcoOpeningTime + PRE_ICO_DURATION;
        closingTime = icoOpeningTime + ICO_DURATION;
    }

    


    function () payable external {
        create();
    }

    




    function setBounty(address _bounty) onlyOwner external returns (bool success) {
        require(_bounty != address(0));
        bounty = _bounty;
        return true;
    }

    




    function create() payable whenNotClosed whenNotPaused public returns (bool success) {
        require(msg.value > 0);
        require(now >= preIcoOpeningTime);

        Phases oldPhase = phase;
        uint256 weiToParticipate = msg.value;
        uint256 overpaidWei;

        adjustPhaseBasedOnTime();

        if (phase != Phases.AfterIco) {

            Rates memory rates = getRates();
            uint256 newTokens = weiToParticipate.mul(rates.total);
            uint256 requestedSupply = totalSupply.add(newTokens);

            uint256 oversoldTokens = computeOversoldAndAdjustPhase(requestedSupply);
            overpaidWei = (oversoldTokens > 0) ? oversoldTokens.div(rates.total) : 0;

            if (overpaidWei > 0) {
                weiToParticipate = msg.value.sub(overpaidWei);
                newTokens = weiToParticipate.mul(rates.total);
                requestedSupply = totalSupply.add(newTokens);
            }

            
            totalSupply = requestedSupply;
            balances[msg.sender] = balances[msg.sender].add(weiToParticipate.mul(rates.toSender));
            balances[owner] = balances[owner].add(weiToParticipate.mul(rates.toOwner));
            balances[bounty] = balances[bounty].add(weiToParticipate.mul(rates.toBounty));

            
            totalProceeds = totalProceeds.add(weiToParticipate);
            owner.transfer(weiToParticipate);
            if (overpaidWei > 0) {
                setWithdrawal(msg.sender, overpaidWei);
            }

            
            NewTokens(newTokens);
            NewFunds(msg.sender, weiToParticipate);

        } else {
            setWithdrawal(msg.sender, msg.value);
        }

        if (phase != oldPhase) {
            logShiftAndBookAward();
        }

        return true;
    }

    


    function returnWei() onlyOwner whenClosed afterWithdrawPause external {
        owner.transfer(this.balance);
    }

    function adjustPhaseBasedOnTime() internal {

        if (now >= closingTime) {
            if (phase != Phases.AfterIco) {
                phase = Phases.AfterIco;
            }
        } else if (now >= icoOpeningTime) {
            if (phase != Phases.MainIco) {
                phase = Phases.MainIco;
            }
        } else if (phase == Phases.PreStart) {
            setDefaultParamsIfNeeded();
            phase = Phases.PreIcoA;
        }
    }

    function setDefaultParamsIfNeeded() internal {
        if (bounty == address(0)) {
            bounty = owner;
        }
        if (upgradeMaster == address(0)) {
            upgradeMaster = owner;
        }
        if (pauseMaster == address(0)) {
            pauseMaster = owner;
        }
    }

    function computeOversoldAndAdjustPhase(uint256 newTotalSupply) internal returns (uint256 oversoldTokens) {

        if ((phase == Phases.PreIcoA) &&
            (newTotalSupply >= PRE_ICO_LIMIT)) {
            phase = Phases.PreIcoB;
            oversoldTokens = newTotalSupply.sub(PRE_ICO_LIMIT);

        } else if (newTotalSupply >= TOTAL_LIMIT) {
            phase = Phases.AfterIco;
            oversoldTokens = newTotalSupply.sub(TOTAL_LIMIT);

        } else {
            oversoldTokens = 0;
        }

        return oversoldTokens;
    }

    function getRates() internal returns (Rates rates) {

        if (phase == Phases.PreIcoA) {
            rates.toSender = TO_SENDER_RATE_A;
            rates.toOwner = TO_OWNER_RATE_A;
            rates.toBounty = TO_BOUNTY_RATE_A;
            rates.total = TOTAL_RATE_A;
        } else if (phase == Phases.PreIcoB) {
            rates.toSender = TO_SENDER_RATE_B;
            rates.toOwner = TO_OWNER_RATE_B;
            rates.toBounty = TO_BOUNTY_RATE_B;
            rates.total = TOTAL_RATE_B;
        } else {
            rates.toSender = TO_SENDER_RATE;
            rates.toOwner = TO_OWNER_RATE;
            rates.toBounty = TO_BOUNTY_RATE;
            rates.total = TOTAL_RATE;
        }
        return rates;
    }

    function logShiftAndBookAward() internal {
        uint256 shiftAward;

        if ((phase == Phases.PreIcoA) || (phase == Phases.PreIcoB)) {
            shiftAward = PRE_OPENING_AWARD;

        } else if (phase == Phases.MainIco) {
            shiftAward = ICO_OPENING_AWARD;

        } else {
            shiftAward = ICO_CLOSING_AWARD;
            returnAllowedTime = uint64(now + RETURN_WEI_PAUSE);
        }

        setWithdrawal(msg.sender, shiftAward);
        NewPhase(phase);
    }

    





    function transfer(address _to, uint256 _value)
        whenNotPaused limitForOwner public returns (bool success)
    {
        return super.transfer(_to, _value);
    }

    






    function transferFrom(address _from, address _to, uint256 _value)
        whenNotPaused limitForOwner public returns (bool success)
    {
        return super.transferFrom(_from, _to, _value);
    }

    






    function approve(address _spender, uint256 _value)
        whenNotPaused limitForOwner public returns (bool success)
    {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        return super.approve(_spender, _value);
    }

    





    function increaseApproval(address _spender, uint _addedValue)
        whenNotPaused limitForOwner public returns (bool success)
    {
        return super.increaseApproval(_spender, _addedValue);
    }

    





    function decreaseApproval(address _spender, uint _subtractedValue)
        whenNotPaused limitForOwner public returns (bool success)
    {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    



    function withdraw() whenNotPaused public returns (bool success) {
        return super.withdraw();
    }

    


    modifier whenClosed() {
        require(phase == Phases.AfterIco);
        _;
    }

    


    modifier whenNotClosed() {
        require(phase != Phases.AfterIco);
        _;
    }

    


    modifier limitForOwner() {
        require((msg.sender != owner) || (phase == Phases.AfterIco));
        _;
    }

    


    modifier afterWithdrawPause() {
        require(now > returnAllowedTime);
        _;
    }

}