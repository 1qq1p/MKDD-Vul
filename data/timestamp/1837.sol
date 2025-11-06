pragma solidity 0.4.25;


contract NeumarkIssuanceCurve {

    
    
    

    
    uint256 private constant NEUMARK_CAP = 1500000000000000000000000000;

    
    uint256 private constant INITIAL_REWARD_FRACTION = 6500000000000000000;

    
    uint256 private constant ISSUANCE_LIMIT_EUR_ULPS = 8300000000000000000000000000;

    
    uint256 private constant LINEAR_APPROX_LIMIT_EUR_ULPS = 2100000000000000000000000000;
    uint256 private constant NEUMARKS_AT_LINEAR_LIMIT_ULPS = 1499832501287264827896539871;

    uint256 private constant TOT_LINEAR_NEUMARKS_ULPS = NEUMARK_CAP - NEUMARKS_AT_LINEAR_LIMIT_ULPS;
    uint256 private constant TOT_LINEAR_EUR_ULPS = ISSUANCE_LIMIT_EUR_ULPS - LINEAR_APPROX_LIMIT_EUR_ULPS;

    
    
    

    
    
    
    function incremental(uint256 totalEuroUlps, uint256 euroUlps)
        public
        pure
        returns (uint256 neumarkUlps)
    {
        require(totalEuroUlps + euroUlps >= totalEuroUlps);
        uint256 from = cumulative(totalEuroUlps);
        uint256 to = cumulative(totalEuroUlps + euroUlps);
        
        
        assert(to >= from);
        return to - from;
    }

    
    
    
    function incrementalInverse(uint256 totalEuroUlps, uint256 burnNeumarkUlps)
        public
        pure
        returns (uint256 euroUlps)
    {
        uint256 totalNeumarkUlps = cumulative(totalEuroUlps);
        require(totalNeumarkUlps >= burnNeumarkUlps);
        uint256 fromNmk = totalNeumarkUlps - burnNeumarkUlps;
        uint newTotalEuroUlps = cumulativeInverse(fromNmk, 0, totalEuroUlps);
        
        assert(totalEuroUlps >= newTotalEuroUlps);
        return totalEuroUlps - newTotalEuroUlps;
    }

    
    
    
    
    
    function incrementalInverse(uint256 totalEuroUlps, uint256 burnNeumarkUlps, uint256 minEurUlps, uint256 maxEurUlps)
        public
        pure
        returns (uint256 euroUlps)
    {
        uint256 totalNeumarkUlps = cumulative(totalEuroUlps);
        require(totalNeumarkUlps >= burnNeumarkUlps);
        uint256 fromNmk = totalNeumarkUlps - burnNeumarkUlps;
        uint newTotalEuroUlps = cumulativeInverse(fromNmk, minEurUlps, maxEurUlps);
        
        assert(totalEuroUlps >= newTotalEuroUlps);
        return totalEuroUlps - newTotalEuroUlps;
    }

    
    
    
    function cumulative(uint256 euroUlps)
        public
        pure
        returns(uint256 neumarkUlps)
    {
        
        if (euroUlps >= ISSUANCE_LIMIT_EUR_ULPS) {
            return NEUMARK_CAP;
        }
        
        
        if (euroUlps >= LINEAR_APPROX_LIMIT_EUR_ULPS) {
            
            return NEUMARKS_AT_LINEAR_LIMIT_ULPS + (TOT_LINEAR_NEUMARKS_ULPS * (euroUlps - LINEAR_APPROX_LIMIT_EUR_ULPS)) / TOT_LINEAR_EUR_ULPS;
        }

        
        
        
        
        
        
        uint256 d = 230769230769230769230769231; 
        uint256 term = NEUMARK_CAP;
        uint256 sum = 0;
        uint256 denom = d;
        do assembly {
            
            
            term  := div(mul(term, euroUlps), denom)
            sum   := add(sum, term)
            denom := add(denom, d)
            
            term  := div(mul(term, euroUlps), denom)
            sum   := sub(sum, term)
            denom := add(denom, d)
        } while (term != 0);
        return sum;
    }

    
    
    
    
    
    
    
    function cumulativeInverse(uint256 neumarkUlps, uint256 minEurUlps, uint256 maxEurUlps)
        public
        pure
        returns (uint256 euroUlps)
    {
        require(maxEurUlps >= minEurUlps);
        require(cumulative(minEurUlps) <= neumarkUlps);
        require(cumulative(maxEurUlps) >= neumarkUlps);
        uint256 min = minEurUlps;
        uint256 max = maxEurUlps;

        
        while (max > min) {
            uint256 mid = (max + min) / 2;
            uint256 val = cumulative(mid);
            
            
            
            
            


            
            
            
            
            
            if (val < neumarkUlps) {
                min = mid + 1;
            } else {
                max = mid;
            }
        }
        
        
        
        
        
        
        
        
        return max;
    }

    function neumarkCap()
        public
        pure
        returns (uint256)
    {
        return NEUMARK_CAP;
    }

    function initialRewardFraction()
        public
        pure
        returns (uint256)
    {
        return INITIAL_REWARD_FRACTION;
    }
}


