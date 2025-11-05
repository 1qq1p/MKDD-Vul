







pragma solidity ^0.4.11;







contract FlightDelayDatabaseModel {

    
    enum Acc {
        Premium,      
        RiskFund,     
        Payout,       
        Balance,      
        Reward,       
        OraclizeCosts 
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


    
    enum policyState { Applied, Accepted, Revoked, PaidOut, Expired, Declined, SendFailed }

    
    enum oraclizeState { ForUnderwriting, ForPayout }

    
    enum Currency { ETH, EUR, USD, GBP }

    
    
    struct Policy {
        
        address customer;

        
        uint premium;
        
        
        bytes32 riskId;
        
        
        
        
        
        uint weight;
        
        uint calculatedPayout;
        
        uint actualPayout;

        
        
        policyState state;
        
        uint stateTime;
        
        bytes32 stateMessage;
        
        bytes proof;
        
        Currency currency;
        
        bytes32 customerExternalId;
    }

    
    
    
    
    struct Risk {
        
        bytes32 carrierFlightNumber;
        
        bytes32 departureYearMonthDay;
        
        uint arrivalTime;
        
        uint delayInMinutes;
        
        uint8 delay;
        
        uint cumulatedWeightedPremium;
        
        uint premiumMultiplier;
    }

    
    
    
    struct OraclizeCallback {
        
        uint policyId;
        
        oraclizeState oState;
        
        uint oraclizeTime;
    }

    struct Customer {
        bytes32 customerExternalId;
        bool identityConfirmed;
    }
}
