pragma solidity ^0.4.4;



























contract TokenTrader is Owned {

    address public asset;       
    uint256 public buyPrice;    
    uint256 public sellPrice;   
    uint256 public units;       

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
        uint256 _buyPrice,
        uint256 _sellPrice,
        uint256 _units,
        bool    _buysTokens,
        bool    _sellsTokens
    ) {
        asset       = _asset;
        buyPrice    = _buyPrice;
        sellPrice   = _sellPrice;
        units       = _units;
        buysTokens  = _buysTokens;
        sellsTokens = _sellsTokens;
        ActivatedEvent(buysTokens, sellsTokens);
    }

    
    
    
    
    
    
    
    
    function activate (
        bool _buysTokens,
        bool _sellsTokens
    ) onlyOwner {
        buysTokens  = _buysTokens;
        sellsTokens = _sellsTokens;
        ActivatedEvent(buysTokens, sellsTokens);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function makerDepositEther() payable onlyOwnerOrTokenTraderWithSameOwner {
        MakerDepositedEther(msg.value);
    }

    
    
    
    
    
    
    
    
    
    
    function makerWithdrawAsset(uint256 tokens) onlyOwner returns (bool ok) {
        MakerWithdrewAsset(tokens);
        return ERC20(asset).transfer(owner, tokens);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function makerTransferAsset(
        TokenTrader toTokenTrader,
        uint256 tokens
    ) onlyOwner returns (bool ok) {
        if (owner != toTokenTrader.owner() || asset != toTokenTrader.asset()) {
            throw;
        }
        MakerTransferredAsset(toTokenTrader, tokens);
        return ERC20(asset).transfer(toTokenTrader, tokens);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    function makerWithdrawERC20Token(
        address tokenAddress,
        uint256 tokens
    ) onlyOwner returns (bool ok) {
        MakerWithdrewERC20Token(tokenAddress, tokens);
        return ERC20(tokenAddress).transfer(owner, tokens);
    }

    
    
    
    
    
    
    
    function makerWithdrawEther(uint256 ethers) onlyOwner returns (bool ok) {
        if (this.balance >= ethers) {
            MakerWithdrewEther(ethers);
            return owner.send(ethers);
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function makerTransferEther(
        TokenTrader toTokenTrader,
        uint256 ethers
    ) onlyOwner returns (bool ok) {
        if (owner != toTokenTrader.owner() || asset != toTokenTrader.asset()) {
            throw;
        }
        if (this.balance >= ethers) {
            MakerTransferredEther(toTokenTrader, ethers);
            toTokenTrader.makerDepositEther.value(ethers)();
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    function takerBuyAsset() payable {
        if (sellsTokens || msg.sender == owner) {
            
            uint order    = msg.value / sellPrice;
            
            uint can_sell = ERC20(asset).balanceOf(address(this)) / units;
            uint256 change = 0;
            if (msg.value > (can_sell * sellPrice)) {
                change  = msg.value - (can_sell * sellPrice);
                order = can_sell;
            }
            if (change > 0) {
                if (!msg.sender.send(change)) throw;
            }
            if (order > 0) {
                if (!ERC20(asset).transfer(msg.sender, order * units)) throw;
            }
            TakerBoughtAsset(msg.sender, msg.value, change, order * units);
        }
        
        else if (!msg.sender.send(msg.value)) throw;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function takerSellAsset(uint256 amountOfTokensToSell) {
        if (buysTokens || msg.sender == owner) {
            
            
            uint256 can_buy = this.balance / buyPrice;
            
            
            uint256 order = amountOfTokensToSell / units;
            
            if (order > can_buy) order = can_buy;
            if (order > 0) {
                
                if (!ERC20(asset).transferFrom(msg.sender, address(this), order * units)) throw;
                
                if (!msg.sender.send(order * buyPrice)) throw;
            }
            TakerSoldAsset(msg.sender, amountOfTokensToSell, order * units, order * buyPrice);
        }
    }

    
    function () payable {
        takerBuyAsset();
    }
}

