pragma solidity ^0.4.18;






library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}







contract BitMEDCrowdsale is FinalizableCrowdsale {

    
    
    
    
    
    
    
    
    
    
    uint8 public constant MAX_TOKEN_GRANTEES = 10;

    
    uint256 public constant EXCHANGE_RATE = 210;

    
    uint256 public constant REFUND_DIVISION_RATE = 2;

    
    uint256 public constant MIN_TOKEN_SALE = 125000000000000000000000000;


    
    
    

    


    modifier onlyWhileSale() {
        require(isActive());
        _;
    }

    
    
    

    
    address public walletTeam;      
    address public walletReserve;   
    address public walletCommunity; 

    
    uint256 public fiatRaisedConvertedToWei;

    
    address[] public presaleGranteesMapKeys;
    mapping (address => uint256) public presaleGranteesMap;  

    
    RefundVault public refundVault;

    
    
    
    event GrantAdded(address indexed _grantee, uint256 _amount);

    event GrantUpdated(address indexed _grantee, uint256 _oldAmount, uint256 _newAmount);

    event GrantDeleted(address indexed _grantee, uint256 _hadAmount);

    event FiatRaisedUpdated(address indexed _address, uint256 _fiatRaised);

    event TokenPurchaseWithGuarantee(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    
    
    

    function BitMEDCrowdsale(uint256 _startTime,
    uint256 _endTime,
    address _wallet,
    address _walletTeam,
    address _walletCommunity,
    address _walletReserve,
    BitMEDSmartToken _BitMEDSmartToken,
    RefundVault _refundVault,
    Vault _vault)

    public Crowdsale(_startTime, _endTime, EXCHANGE_RATE, _wallet, _BitMEDSmartToken, _vault) {
        require(_walletTeam != address(0));
        require(_walletCommunity != address(0));
        require(_walletReserve != address(0));
        require(_BitMEDSmartToken != address(0));
        require(_refundVault != address(0));
        require(_vault != address(0));

        walletTeam = _walletTeam;
        walletCommunity = _walletCommunity;
        walletReserve = _walletReserve;

        token = _BitMEDSmartToken;
        refundVault  = _refundVault;

        vault = _vault;

    }

    
    
    

    
    
    function getRate() public view returns (uint256) {
        if (block.timestamp < (startTime.add(24 hours))) {return 700;}
        if (block.timestamp < (startTime.add(3 days))) {return 600;}
        if (block.timestamp < (startTime.add(5 days))) {return 500;}
        if (block.timestamp < (startTime.add(7 days))) {return 400;}
        if (block.timestamp < (startTime.add(10 days))) {return 350;}
        if (block.timestamp < (startTime.add(13 days))) {return 300;}
        if (block.timestamp < (startTime.add(16 days))) {return 285;}
        if (block.timestamp < (startTime.add(19 days))) {return 270;}
        if (block.timestamp < (startTime.add(22 days))) {return 260;}
        if (block.timestamp < (startTime.add(25 days))) {return 250;}
        if (block.timestamp < (startTime.add(28 days))) {return 240;}
        if (block.timestamp < (startTime.add(31 days))) {return 230;}
        if (block.timestamp < (startTime.add(34 days))) {return 225;}
        if (block.timestamp < (startTime.add(37 days))) {return 220;}
        if (block.timestamp < (startTime.add(40 days))) {return 215;}

        return rate;
    }

    
    
    

    
    function finalization() internal {

        super.finalization();

        
        for (uint256 i = 0; i < presaleGranteesMapKeys.length; i++) {
            token.issue(presaleGranteesMapKeys[i], presaleGranteesMap[presaleGranteesMapKeys[i]]);
        }

        
        if(token.totalSupply() <= MIN_TOKEN_SALE){
            uint256 missingTokens = MIN_TOKEN_SALE - token.totalSupply();
            token.issue(walletCommunity, missingTokens);
        }

        
        
        uint256 newTotalSupply = token.totalSupply().mul(400).div(100);

        
        token.issue(walletTeam, newTotalSupply.mul(10).div(100));

        
        token.issue(walletCommunity, newTotalSupply.mul(30).div(100));

        
        
        token.issue(walletReserve, newTotalSupply.mul(35).div(100));

        
        token.disableTransfers(false);

        
        token.setDestroyEnabled(true);

        
        refundVault.enableRefunds();

        
        token.transferOwnership(owner);

        
        refundVault.transferOwnership(owner);

        vault.transferOwnership(owner);

    }

    
    
    
    
    function getTotalFundsRaised() public view returns (uint256) {
        return fiatRaisedConvertedToWei.add(weiRaised);
    }

    
    function isActive() public view returns (bool) {
        return block.timestamp >= startTime && block.timestamp < endTime;
    }

    
    
    
    
    
    
    
    function addUpdateGrantee(address _grantee, uint256 _value) external onlyOwner onlyWhileSale{
        require(_grantee != address(0));
        require(_value > 0);

        
        if (presaleGranteesMap[_grantee] == 0) {
            require(presaleGranteesMapKeys.length < MAX_TOKEN_GRANTEES);
            presaleGranteesMapKeys.push(_grantee);
            GrantAdded(_grantee, _value);
        }
        else {
            GrantUpdated(_grantee, presaleGranteesMap[_grantee], _value);
        }

        presaleGranteesMap[_grantee] = _value;
    }

    
    
    function deleteGrantee(address _grantee) external onlyOwner onlyWhileSale {
    require(_grantee != address(0));
        require(presaleGranteesMap[_grantee] != 0);

        
        delete presaleGranteesMap[_grantee];

        
        uint256 index;
        for (uint256 i = 0; i < presaleGranteesMapKeys.length; i++) {
            if (presaleGranteesMapKeys[i] == _grantee) {
                index = i;
                break;
            }
        }
        presaleGranteesMapKeys[index] = presaleGranteesMapKeys[presaleGranteesMapKeys.length - 1];
        delete presaleGranteesMapKeys[presaleGranteesMapKeys.length - 1];
        presaleGranteesMapKeys.length--;

        GrantDeleted(_grantee, presaleGranteesMap[_grantee]);
    }

    
    
    
    
    function setFiatRaisedConvertedToWei(uint256 _fiatRaisedConvertedToWei) external onlyOwner onlyWhileSale {
        fiatRaisedConvertedToWei = _fiatRaisedConvertedToWei;
        FiatRaisedUpdated(msg.sender, fiatRaisedConvertedToWei);
    }

    
    
    function claimTokenOwnership() external onlyOwner {
        token.claimOwnership();
    }

    
    
    function claimRefundVaultOwnership() external onlyOwner {
        refundVault.claimOwnership();
    }

    
    
    function claimVaultOwnership() external onlyOwner {
        vault.claimOwnership();
    }

    
    function buyTokensWithGuarantee() public payable {
        require(validPurchase());

        uint256 weiAmount = msg.value;

        require(weiAmount>500000000000000000);

        
        uint256 tokens = weiAmount.mul(getRate());
        tokens = tokens.div(REFUND_DIVISION_RATE);

        
        weiRaised = weiRaised.add(weiAmount);

        token.issue(address(refundVault), tokens);
        refundVault.deposit.value(msg.value)(msg.sender, tokens);

        TokenPurchaseWithGuarantee(msg.sender, address(refundVault), weiAmount, tokens);
    }
}