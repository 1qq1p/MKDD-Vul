pragma solidity 0.4.15;


contract TokenMetadata is ITokenMetadata {

    
    
    

    
    string private NAME;

    
    string private SYMBOL;

    
    uint8 private DECIMALS;

    
    string private VERSION;

    
    
    

    
    
    
    
    
    function TokenMetadata(
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol,
        string version
    )
        public
    {
        NAME = tokenName;                                 
        SYMBOL = tokenSymbol;                             
        DECIMALS = decimalUnits;                          
        VERSION = version;
    }

    
    
    

    function name()
        public
        constant
        returns (string)
    {
        return NAME;
    }

    function symbol()
        public
        constant
        returns (string)
    {
        return SYMBOL;
    }

    function decimals()
        public
        constant
        returns (uint8)
    {
        return DECIMALS;
    }

    function version()
        public
        constant
        returns (string)
    {
        return VERSION;
    }
}
