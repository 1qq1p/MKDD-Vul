



































pragma solidity 0.4.25;






contract ExchangeRates is SelfDestructible {

    using SafeMath for uint;

    
    mapping(bytes4 => uint) public rates;

    
    mapping(bytes4 => uint) public lastRateUpdateTimes;

    
    address public oracle;

    
    uint constant ORACLE_FUTURE_LIMIT = 10 minutes;

    
    uint public rateStalePeriod = 3 hours;

    
    
    
    bytes4[5] public xdrParticipants;

    
    

    






    constructor(
        
        address _owner,

        
        address _oracle,
        bytes4[] _currencyKeys,
        uint[] _newRates
    )
        
        SelfDestructible(_owner)
        public
    {
        require(_currencyKeys.length == _newRates.length, "Currency key length and rate length must match.");

        oracle = _oracle;

        
        rates["sUSD"] = SafeDecimalMath.unit();
        lastRateUpdateTimes["sUSD"] = now;

        
        
        
        
        
        
        
        xdrParticipants = [
            bytes4("sUSD"),
            bytes4("sAUD"),
            bytes4("sCHF"),
            bytes4("sEUR"),
            bytes4("sGBP")
        ];

        internalUpdateRates(_currencyKeys, _newRates, now);
    }

    

    







    function updateRates(bytes4[] currencyKeys, uint[] newRates, uint timeSent)
        external
        onlyOracle
        returns(bool)
    {
        return internalUpdateRates(currencyKeys, newRates, timeSent);
    }

    







    function internalUpdateRates(bytes4[] currencyKeys, uint[] newRates, uint timeSent)
        internal
        returns(bool)
    {
        require(currencyKeys.length == newRates.length, "Currency key array length must match rates array length.");
        require(timeSent < (now + ORACLE_FUTURE_LIMIT), "Time is too far into the future");

        
        for (uint i = 0; i < currencyKeys.length; i++) {
            
            
            
            require(newRates[i] != 0, "Zero is not a valid rate, please call deleteRate instead.");
            require(currencyKeys[i] != "sUSD", "Rate of sUSD cannot be updated, it's always UNIT.");

            
            if (timeSent >= lastRateUpdateTimes[currencyKeys[i]]) {
                
                rates[currencyKeys[i]] = newRates[i];
                lastRateUpdateTimes[currencyKeys[i]] = timeSent;
            }
        }

        emit RatesUpdated(currencyKeys, newRates);

        
        updateXDRRate(timeSent);

        return true;
    }

    


    function updateXDRRate(uint timeSent)
        internal
    {
        uint total = 0;

        for (uint i = 0; i < xdrParticipants.length; i++) {
            total = rates[xdrParticipants[i]].add(total);
        }

        
        rates["XDR"] = total;

        
        lastRateUpdateTimes["XDR"] = timeSent;

        
        
        bytes4[] memory eventCurrencyCode = new bytes4[](1);
        eventCurrencyCode[0] = "XDR";

        uint[] memory eventRate = new uint[](1);
        eventRate[0] = rates["XDR"];

        emit RatesUpdated(eventCurrencyCode, eventRate);
    }

    



    function deleteRate(bytes4 currencyKey)
        external
        onlyOracle
    {
        require(rates[currencyKey] > 0, "Rate is zero");

        delete rates[currencyKey];
        delete lastRateUpdateTimes[currencyKey];

        emit RateDeleted(currencyKey);
    }

    



    function setOracle(address _oracle)
        external
        onlyOwner
    {
        oracle = _oracle;
        emit OracleUpdated(oracle);
    }

    



    function setRateStalePeriod(uint _time)
        external
        onlyOwner
    {
        rateStalePeriod = _time;
        emit RateStalePeriodUpdated(rateStalePeriod);
    }

    

    


    function rateForCurrency(bytes4 currencyKey)
        public
        view
        returns (uint)
    {
        return rates[currencyKey];
    }

    


    function ratesForCurrencies(bytes4[] currencyKeys)
        public
        view
        returns (uint[])
    {
        uint[] memory _rates = new uint[](currencyKeys.length);

        for (uint8 i = 0; i < currencyKeys.length; i++) {
            _rates[i] = rates[currencyKeys[i]];
        }

        return _rates;
    }

    


    function lastRateUpdateTimeForCurrency(bytes4 currencyKey)
        public
        view
        returns (uint)
    {
        return lastRateUpdateTimes[currencyKey];
    }

    


    function lastRateUpdateTimesForCurrencies(bytes4[] currencyKeys)
        public
        view
        returns (uint[])
    {
        uint[] memory lastUpdateTimes = new uint[](currencyKeys.length);

        for (uint8 i = 0; i < currencyKeys.length; i++) {
            lastUpdateTimes[i] = lastRateUpdateTimes[currencyKeys[i]];
        }

        return lastUpdateTimes;
    }

    


    function rateIsStale(bytes4 currencyKey)
        external
        view
        returns (bool)
    {
        
        if (currencyKey == "sUSD") return false;

        return lastRateUpdateTimes[currencyKey].add(rateStalePeriod) < now;
    }

    


    function anyRateIsStale(bytes4[] currencyKeys)
        external
        view
        returns (bool)
    {
        
        uint256 i = 0;

        while (i < currencyKeys.length) {
            
            if (currencyKeys[i] != "sUSD" && lastRateUpdateTimes[currencyKeys[i]].add(rateStalePeriod) < now) {
                return true;
            }
            i += 1;
        }

        return false;
    }

    

    modifier onlyOracle
    {
        require(msg.sender == oracle, "Only the oracle can perform this action");
        _;
    }

    

    event OracleUpdated(address newOracle);
    event RateStalePeriodUpdated(uint rateStalePeriod);
    event RatesUpdated(bytes4[] currencyKeys, uint[] newRates);
    event RateDeleted(bytes4 currencyKey);
}





























































































































