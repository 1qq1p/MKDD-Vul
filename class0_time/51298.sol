pragma solidity ^0.4.21;








contract PrivatePreSale is Claimable, KYCWhitelist, Pausable {
  using SafeMath for uint256;

  
  
  address public constant FUNDS_WALLET = 0xDc17D222Bc3f28ecE7FCef42EDe0037C739cf28f;
  
  address public constant TOKEN_WALLET = 0x1EF91464240BB6E0FdE7a73E0a6f3843D3E07601;
  
  address public constant TOKEN_ADDRESS = 0x14121EEe7995FFDF47ED23cfFD0B5da49cbD6EB3;
  
  address public constant LOCKUP_WALLET = 0xaB18B66F75D13a38158f9946662646105C3bC45D;
  
  ERC20 public constant TOKEN = ERC20(TOKEN_ADDRESS);
  
  uint256 public constant TOKENS_PER_ETH = 4970;
  
  uint256 public constant MAX_TOKENS = 20000000 * (10**18) - 119545639989300000000000;
  
  uint256 public constant MIN_TOKEN_INVEST = 4970 * (10**18);
  
  uint256 public START_DATE = 1531915200;

  
  
  

  
  uint256 public weiRaised;
  
  uint256 public tokensIssued;
  
  bool public closed;

  
  
  

  






  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  
  
  


  constructor() public {
    require(TOKENS_PER_ETH > 0);
    require(FUNDS_WALLET != address(0));
    require(TOKEN_WALLET != address(0));
    require(TOKEN_ADDRESS != address(0));
    require(MAX_TOKENS > 0);
    require(MIN_TOKEN_INVEST >= 0);
  }

  
  
  

  



  function capReached() public view returns (bool) {
    return tokensIssued >= MAX_TOKENS;
  }

  


  function closeSale() public onlyOwner {
    require(!closed);
    closed = true;
  }

  



  function getTokenAmount(uint256 _weiAmount) public pure returns (uint256) {
    
    return _weiAmount.mul(TOKENS_PER_ETH);
  }

  


  function () external payable {
    buyTokens(msg.sender);
  }

  
  
  

   



  function buyTokens(address _beneficiary) internal whenNotPaused {
    
    uint256 weiAmount = msg.value;

    
    uint256 tokenAmount = getTokenAmount(weiAmount);

    
    preValidateChecks(_beneficiary, weiAmount, tokenAmount);
    
    
    tokensIssued = tokensIssued.add(tokenAmount);
    weiRaised = weiRaised.add(weiAmount);

    
    TOKEN.transferFrom(TOKEN_WALLET, LOCKUP_WALLET, tokenAmount);

    
    FUNDS_WALLET.transfer(msg.value);

    
    emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokenAmount);
  }

  





  function preValidateChecks(address _beneficiary, uint256 _weiAmount, uint256 _tokenAmount) internal view {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
    require(now >= START_DATE);
    require(!closed);

    
    validateWhitelisted(_beneficiary);

    
    require(_tokenAmount >= MIN_TOKEN_INVEST);

    
    require(tokensIssued.add(_tokenAmount) <= MAX_TOKENS);
  }
}