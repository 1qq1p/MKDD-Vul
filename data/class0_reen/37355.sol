pragma solidity ^0.4.23;


































pragma solidity ^0.4.18;

contract OraclizeCrowdsale is usingOraclize, MultiCurrencyRates {
  FiatContractInterface public fiatContract;
  PhaseCrowdsaleInterface public phaseCrowdsale;
  CryptonityCrowdsaleInterface private crowdsaleContract;

  
  uint256 public btcRaised;
  uint256 public ltcRaised;
  uint256 public bnbRaised;
  uint256 public bchRaised;

  enum OraclizeState { ForPurchase, ForFinalization }
  struct OraclizeCallback {
    address ethWallet;
    string currencyWallet;
    uint256 currencyAmount;
    bool exist;
    OraclizeState oState;
  }
  struct MultiCurrencyInvestor {
    string currencyWallet;
    uint256 currencyAmount;
  }
  mapping(bytes32 => OraclizeCallback) public oraclizeCallbacks;
  mapping(bytes32 => MultiCurrencyInvestor) public multiCurrencyInvestors;

  event LogInfo(string description);
  event LogError(string description);
  event LogCurrencyRateReceived(uint256 rate);

  constructor(
    address _fiatContract,
    address _phaseCrowdsale
    )
    public
      MultiCurrencyRates(_fiatContract)
  {
    phaseCrowdsale = PhaseCrowdsaleInterface(_phaseCrowdsale);
    
    
    oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
  }

  


  modifier onlyCrowdsaleContract {
    require(msg.sender == address(crowdsaleContract));
    _;
  }

  


  function chargeBalance() public payable onlyOwner {
    
  }

  function setCrowdsaleContract(address _crowdsaleContract) public onlyOwner {
    crowdsaleContract = CryptonityCrowdsaleInterface(_crowdsaleContract);
  }

    




  function getHashedCurrencyWalletAddress(string _wallet) private pure returns(bytes32) {
    return keccak256(abi.encodePacked(_wallet));
  }

  







  
  function oraclizeCreateQuery(string _oraclizeUrl, address _ethWallet, string _currencyWallet, uint256 _currencyAmount, OraclizeState _oState) private {
    
    if (oraclize_getPrice("URL") > address(this).balance) {
      emit LogError("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
      revert();
    } else {
      emit LogInfo("Oraclize query was sent, standing by for the answer..");
      bytes32 queryId;
      if(_oState == OraclizeState.ForFinalization) {
        queryId = oraclize_query("URL", _oraclizeUrl, 500000);
      } else {
        queryId = oraclize_query("URL", _oraclizeUrl);
      }
      
      oraclizeCallbacks[queryId] = OraclizeCallback(_ethWallet, _currencyWallet, _currencyAmount, true, _oState);
    }
  }

    





  function buyTokensWithBNB(address _ethWallet, string _bnbWallet, uint256 _bnbAmount) public payable onlyCrowdsaleContract {
    require(_ethWallet != address(0));
    oraclizeCreateQuery(
      "json(https://min-api.cryptocompare.com/data/price?fsym=BNB&tsyms=USD).USD",
      _ethWallet,
      _bnbWallet,
      _bnbAmount,
      OraclizeState.ForPurchase
    );
    bnbRaised = bnbRaised.add(_bnbAmount);
  }

  





  function buyTokensWithBCH(address _ethWallet, string _bchWallet, uint256 _bchAmount) public payable onlyCrowdsaleContract {
    require(_ethWallet != address(0));
    oraclizeCreateQuery(
      "json(https://min-api.cryptocompare.com/data/price?fsym=BCH&tsyms=USD).USD",
      _ethWallet,
      _bchWallet,
      _bchAmount,
      OraclizeState.ForPurchase
    );
    bchRaised = bchRaised.add(_bchAmount);
  }

    





  function buyTokensWithBTC(address _ethWallet, string _btcWallet, uint256 _btcAmount) public onlyCrowdsaleContract {
    require(_ethWallet != address(0));
    performPurchaseWithSpecificCurrency(_ethWallet, _btcWallet, _btcAmount, getUSDCentToBTCSatoshiRate().mul(1 ether));
    btcRaised = btcRaised.add(_btcAmount);
  }

  





  function buyTokensWithLTC(address _ethWallet, string _ltcWallet, uint256 _ltcAmount) public onlyCrowdsaleContract {
    require(_ethWallet != address(0));
    performPurchaseWithSpecificCurrency(_ethWallet, _ltcWallet, _ltcAmount, getUSDCentToLTCSatoshiRate().mul(1 ether));
    ltcRaised = ltcRaised.add(_ltcAmount);
  }

  




  function finalize() public onlyCrowdsaleContract {
    oraclizeCreateQuery(
      "json(https://min-api.cryptocompare.com/data/pricemulti?fsyms=BNB,BCH&tsyms=USD).$",
      address(0),
      " ",
      0,
      OraclizeState.ForFinalization
    );
  }

  






  function performPurchaseWithSpecificCurrency(address _ethWallet, string _currencyWallet, uint256 _currencyAmount, uint256 _rate)
    private
  {
    

    uint256 token = _currencyAmount.mul(1 ether).mul(1 ether).div(_rate).div(phaseCrowdsale.getCurrentTokenPriceInCents());
    crowdsaleContract.processPurchase(_ethWallet, token);

    
    bytes32 hashedCurrencyWalletAddress = getHashedCurrencyWalletAddress(_currencyWallet);
    multiCurrencyInvestors[hashedCurrencyWalletAddress] = MultiCurrencyInvestor(
      _currencyWallet,
      multiCurrencyInvestors[hashedCurrencyWalletAddress].currencyAmount.add(_currencyAmount)
    );
  }

  





  function __callback(bytes32 queryId, string result, bytes proof) public {
    require(msg.sender == oraclize_cbAddress());
    require(oraclizeCallbacks[queryId].exist);

    OraclizeCallback memory cb = oraclizeCallbacks[queryId];

    if (cb.oState == OraclizeState.ForPurchase) {
      uint256 usdCentToCurrencyRate = parseInt(result, 2);
      uint256 currencyToUSDCentRate = uint256(1 ether).div(usdCentToCurrencyRate);
      emit LogCurrencyRateReceived(usdCentToCurrencyRate);

      performPurchaseWithSpecificCurrency(
        cb.ethWallet,
        cb.currencyWallet,
        cb.currencyAmount,
        currencyToUSDCentRate
      );

    } else if (cb.oState == OraclizeState.ForFinalization) {
      uint256 usdRaised = calculateCur(result);
      crowdsaleContract.finalizationCallback(usdRaised);
    }

    
    delete oraclizeCallbacks[queryId];
  }

  function calculateCur(string oraclizeResult) private view returns (uint256) {
    uint256 usdRaised = btcRaised.div(getUSDCentToBTCSatoshiRate())
      .add(ltcRaised.div(getUSDCentToLTCSatoshiRate()))
      .add(bnbRaised.mul(getBNBToUSDCentRate(oraclizeResult)))
      .add(bchRaised.mul(getBCHToUSDCentRate(oraclizeResult)));
    return usdRaised;
  }
    




  function getMultiCurrencyInvestorContribution(string _currencyWallet) public view returns(uint256) {
    bytes32 hashedCurrencyWalletAddress = getHashedCurrencyWalletAddress(_currencyWallet);
    return  multiCurrencyInvestors[hashedCurrencyWalletAddress].currencyAmount;
  }
}