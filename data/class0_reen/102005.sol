pragma solidity >=0.4.25 <0.6.0;

pragma experimental ABIEncoderV2;














contract NullSettlementState is Ownable, Servable, CommunityVotable {
    using SafeMathIntLib for int256;
    using SafeMathUintLib for uint256;

    
    
    
    string constant public SET_MAX_NULL_NONCE_ACTION = "set_max_null_nonce";
    string constant public SET_MAX_NONCE_ACTION = "set_max_nonce";

    
    
    
    uint256 public maxNullNonce;

    mapping(address => mapping(address => mapping(uint256 => uint256))) public walletCurrencyMaxNonce;

    
    
    
    event SetMaxNullNonceEvent(uint256 maxNullNonce);
    event SetMaxNonceByWalletAndCurrencyEvent(address wallet, MonetaryTypesLib.Currency currency,
        uint256 maxNonce);
    event UpdateMaxNullNonceFromCommunityVoteEvent(uint256 maxNullNonce);

    
    
    
    constructor(address deployer) Ownable(deployer) public {
    }

    
    
    
    
    
    function setMaxNullNonce(uint256 _maxNullNonce)
    public
    onlyEnabledServiceAction(SET_MAX_NULL_NONCE_ACTION)
    {
        
        maxNullNonce = _maxNullNonce;

        
        emit SetMaxNullNonceEvent(_maxNullNonce);
    }

    
    
    
    
    function maxNonceByWalletAndCurrency(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (uint256) {
        return walletCurrencyMaxNonce[wallet][currency.ct][currency.id];
    }

    
    
    
    
    function setMaxNonceByWalletAndCurrency(address wallet, MonetaryTypesLib.Currency memory currency,
        uint256 _maxNullNonce)
    public
    onlyEnabledServiceAction(SET_MAX_NONCE_ACTION)
    {
        
        walletCurrencyMaxNonce[wallet][currency.ct][currency.id] = _maxNullNonce;

        
        emit SetMaxNonceByWalletAndCurrencyEvent(wallet, currency, _maxNullNonce);
    }

    
    function updateMaxNullNonceFromCommunityVote()
    public
    {
        uint256 _maxNullNonce = communityVote.getMaxNullNonce();
        if (0 == _maxNullNonce)
            return;

        maxNullNonce = _maxNullNonce;

        
        emit UpdateMaxNullNonceFromCommunityVoteEvent(maxNullNonce);
    }
}
























