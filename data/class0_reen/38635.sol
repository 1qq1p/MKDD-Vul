contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

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


contract TokenTrader is Owned 
{
    address public exchange;    
    address public asset;       
    uint256 public buyPrice;    
    uint256 public sellPrice;   
    uint256 public units;       
    uint256 public exchFee;     

    bool public buysTokens;     
    bool public sellsTokens;    

    event ActivatedEvent(bool buys, bool sells);
    event MakerDepositedEther(uint256 amount);
    event MakerWithdrewAsset(uint256 tokens);
    event MakerTransferredAsset(address toTokenTrader, uint256 tokens);
    event MakerWithdrewERC20Token(address tokenAddress, uint256 tokens);
    event MakerWithdrewEther(uint256 ethers);
    event MakerTransferredEther(address toTokenTrader, uint256 ethers);
    event TakerBoughtAsset(address indexed buyer, uint256 ethersSent,
        uint256 ethersReturned, uint256 tokensBought);
    event TakerSoldAsset(address indexed seller, uint256 amountOfTokensToSell,
        uint256 tokensSold, uint256 etherValueOfTokensSold);

    
    function TokenTrader (
        address _asset,
        uint256 _exchFee,
        address _exchange,
        uint256 _buyPrice,
        uint256 _sellPrice,
        uint256 _units,
        bool    _buysTokens,
        bool    _sellsTokens
    ) 
    {
        asset       = _asset;
        exchFee     = _exchFee;
        exchange    = _exchange;
        buyPrice    = _buyPrice;
        sellPrice   = _sellPrice;
        units       = _units;
        buysTokens  = _buysTokens;
        sellsTokens = _sellsTokens;
        ActivatedEvent(buysTokens, sellsTokens);
    }

    function activate (
        address _asset,
        uint256 _exchFee,
        address _exchange,
        uint256 _buyPrice,
        uint256 _sellPrice,
        uint256 _units,
        bool    _buysTokens,
        bool    _sellsTokens
    ) onlyOwner 
    {
        require(ERCTW(exchange).transferFrom(owner, exchange, exchFee));
        asset       = _asset;
        exchFee     = _exchFee;
        exchange    = _exchange;
        buyPrice    = _buyPrice;
        sellPrice   = _sellPrice;
        units       = _units;
        buysTokens  = _buysTokens;
        sellsTokens = _sellsTokens;
        ActivatedEvent(buysTokens, sellsTokens);
    }

    function makerDepositEther() payable onlyOwnerOrTokenTraderWithSameOwner 
    {
        require(ERCTW(exchange).transferFrom(this, exchange, exchFee));
        MakerDepositedEther(msg.value);
    }

    function makerWithdrawAsset(uint256 tokens) onlyOwner returns (bool ok) 
    {
        require(ERCTW(exchange).transferFrom(this, exchange, exchFee));
        MakerWithdrewAsset(tokens);
        return ERCTW(asset).transfer(owner, tokens);
    }

    function makerTransferAsset(
        TokenTrader toTokenTrader,
        uint256 tokens
    ) onlyOwner returns (bool ok) 
    {
        require(ERCTW(exchange).transferFrom(this, exchange, exchFee));
        require (owner == toTokenTrader.owner() && asset == toTokenTrader.asset()); 
        MakerTransferredAsset(toTokenTrader, tokens);
        return ERCTW(asset).transfer(toTokenTrader, tokens);
    }

    function makerWithdrawERC20Token(
        address tokenAddress,
        uint256 tokens
    ) onlyOwner returns (bool ok) 
    {
        require(ERCTW(exchange).transferFrom(this, exchange, exchFee));
        MakerWithdrewERC20Token(tokenAddress, tokens);
        return ERCTW(tokenAddress).transfer(owner, tokens);
    }

    function makerWithdrawEther(uint256 ethers) onlyOwner returns (bool ok) 
    {
        require(ERCTW(exchange).transferFrom(this, exchange, exchFee));
        if (this.balance >= ethers) 
        {
            MakerWithdrewEther(ethers);
            return owner.send(ethers);
        }
    }

    function makerTransferEther(
        TokenTrader toTokenTrader,
        uint256 ethers
    ) onlyOwner returns (bool) 
    {
        require(ERCTW(exchange).transferFrom(this, exchange, exchFee));
        require (owner == toTokenTrader.owner() && asset == toTokenTrader.asset()); 
        if (this.balance >= ethers) 
        {
            MakerTransferredEther(toTokenTrader, ethers);
            toTokenTrader.makerDepositEther.value(ethers)();
        }
    }

    function takerBuyAsset() payable 
    {
        require(ERCTW(exchange).transferFrom(this, exchange, exchFee));
        if (sellsTokens || msg.sender == owner) 
        {
            uint order    = msg.value / sellPrice;
            uint can_sell = ERCTW(asset).balanceOf(address(this)) / units;
            uint256 change = 0;
            if (msg.value > (can_sell * sellPrice)) 
            {
                change  = msg.value - (can_sell * sellPrice);
                order = can_sell;
            }
            if (change > 0) 
            {
                require(msg.sender.send(change));
            }
            if (order > 0) 
            {
                require (ERCTW(asset).transfer(msg.sender, order * units));
            }
            TakerBoughtAsset(msg.sender, msg.value, change, order * units);
        }
        else require (msg.sender.send(msg.value));
    }

    function takerSellAsset(uint256 amountOfTokensToSell) public  
    {
        require(ERCTW(exchange).transferFrom(this, exchange, exchFee));
        if (buysTokens || msg.sender == owner) 
        {
            uint256 can_buy = this.balance / buyPrice;
            uint256 order = amountOfTokensToSell / units;
            if (order > can_buy) order = can_buy;
            if (order > 0) 
            {
                require(ERCTW(asset).transferFrom(msg.sender, address(this), order * units));
                require(msg.sender.send(order * buyPrice));
            }
            TakerSoldAsset(msg.sender, amountOfTokensToSell, order * units, order * buyPrice);
        }
    }
    function () payable 
    {
        takerBuyAsset();
    }
}