pragma solidity ^0.4.12;






contract ReporterTokenSale is Ownable {
  using SafeMath for uint256;

  
  ReporterToken public token;

  uint256 public decimals;  
  uint256 public oneCoin;

  
  uint256 public startTimestamp;
  uint256 public endTimestamp;

  
  address public multiSig;

  function setWallet(address _newWallet) public onlyOwner {
    multiSig = _newWallet;
  }

  
  uint256 public rate; 
  uint256 public minContribution = 0.0001 ether;  
  uint256 public maxContribution = 200000 ether;  

  

  
  uint256 public weiRaised;

  
  uint256 public tokenRaised;

  
  uint256 public maxTokens;

  
  uint256 public tokensForSale;  

  
  uint256 public numberOfPurchasers = 0;

  
  address public cs;


  
  bool    public freeForAll = false;

  mapping (address => bool) public authorised; 

  event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);
  event SaleClosed();

  function ReporterTokenSale() public {
    startTimestamp = 1508684400; 
    endTimestamp = 1519657200;   
    multiSig = 0xD00d085F125EAFEA9e8c5D3f4bc25e6D0c93Af0e;

    token = new ReporterToken();
    decimals = token.decimals();
    oneCoin = 10 ** decimals;
    maxTokens = 60 * (10**6) * oneCoin;
    tokensForSale = 36 * (10**6) * oneCoin;
  }

  


  function setTier() internal {
    
    if (tokenRaised <= 9000000 * oneCoin) {
      rate = 1420;
      
      
    } else if (tokenRaised <= 18000000 * oneCoin) {
      rate = 1170;
      
      
    } else {
      rate = 1000;
      
      
    }
  }

  
  function hasEnded() public constant returns (bool) {
    if (now > endTimestamp)
      return true;
    if (tokenRaised >= tokensForSale)
      return true; 
    return false;
  }

  


  modifier onlyCSorOwner() {
    require((msg.sender == owner) || (msg.sender==cs));
    _;
  }
   modifier onlyCS() {
    require(msg.sender == cs);
    _;
  }

  


  modifier onlyAuthorised() {
    require (authorised[msg.sender] || freeForAll);
    require (now >= startTimestamp);
    require (!(hasEnded()));
    require (multiSig != 0x0);
    require(tokensForSale > tokenRaised); 
    _;
  }

  


  function authoriseAccount(address whom) onlyCSorOwner public {
    authorised[whom] = true;
  }

  


  function authoriseManyAccounts(address[] many) onlyCSorOwner public {
    for (uint256 i = 0; i < many.length; i++) {
      authorised[many[i]] = true;
    }
  }

  


  function blockAccount(address whom) onlyCSorOwner public {
    authorised[whom] = false;
   }  
    
  


  function setCS(address newCS) onlyOwner public {
    cs = newCS;
  }

  function placeTokens(address beneficiary, uint256 _tokens) onlyCS public {
    
    require(_tokens != 0);
    require(!hasEnded());
    uint256 amount = 0;
    if (token.balanceOf(beneficiary) == 0) {
      numberOfPurchasers++;
    }
    tokenRaised = tokenRaised.add(_tokens); 
    token.mint(beneficiary, _tokens);
    TokenPurchase(beneficiary, amount, _tokens);
  }

  
  function buyTokens(address beneficiary, uint256 amount) onlyAuthorised internal {

    setTier();

    
    require(amount >= minContribution);
    require(amount <= maxContribution);

    
    uint256 tokens = amount.mul(rate);

    
    weiRaised = weiRaised.add(amount);
    if (token.balanceOf(beneficiary) == 0) {
      numberOfPurchasers++;
    }
    tokenRaised = tokenRaised.add(tokens); 
    token.mint(beneficiary, tokens);
    TokenPurchase(beneficiary, amount, tokens);
    multiSig.transfer(this.balance); 
  }

  
  function finishSale() public onlyOwner {
    require(hasEnded());

    
    uint unassigned;
    if(maxTokens > tokenRaised) {
      unassigned  = maxTokens.sub(tokenRaised);
      token.mint(multiSig,unassigned);
    }
    token.finishMinting();
    token.transferOwnership(owner);
    SaleClosed();
  }

  
  function () public payable {
    buyTokens(msg.sender, msg.value);
  }

  function emergencyERC20Drain( ERC20 oddToken, uint amount ) public {
    oddToken.transfer(owner, amount);
  }
}