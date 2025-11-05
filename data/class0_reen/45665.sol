pragma solidity ^0.4.24;

contract UniswapWrapper is Ownable{

    address public uniswapExchangeAddress;
    address public tradeTokenAddress;
    address public wethAddress;

    constructor(address exchangeAddress, address tokenAddress, address wethAddress)
      public
    {
        uniswapExchangeAddress = exchangeAddress;
        tradeTokenAddress = tokenAddress;
        wethAddress = wethAddress;
    }

    function approve(address token, address proxy)
      public
      onlyOwner
    {
        uint256 MAX_UINT = 2 ** 256 - 1;
        require(ERC20(token).approve(proxy, MAX_UINT), "Approve failed");
    }

    function withdrawETH(uint256 amount)
        public
        onlyOwner
    {
        owner.transfer(amount);
    }

    function withdrawToken(address token, uint256 amount)
        public
        onlyOwner
    {
      require(ERC20(token).transfer(owner, amount), "Withdraw token failed");
    }

    function buyToken(uint256 minTokenAmount, uint256 ethPay, uint256 deadline)
      public
      onlyOwner
    {
      require(WETH(wethAddress).transferFrom(msg.sender, this, ethPay), "Transfer weth failed");
      WETH(wethAddress).withdraw(ethPay);
      uint256 tokenBought = UNISWAP(uniswapExchangeAddress).ethToTokenSwapInput.value(ethPay)(minTokenAmount, deadline);
      ERC20(tradeTokenAddress).transfer(owner, tokenBought);
    }

    function sellToken(uint256 minEthAmount, uint256 tokenAmount, uint256 deadline)
      public
      onlyOwner
    {
      require(ERC20(tradeTokenAddress).transferFrom(msg.sender, this, tokenAmount), "Transfer token failed");
      uint256 ethBought = UNISWAP(uniswapExchangeAddress).tokenToEthSwapInput(tokenAmount, minEthAmount, deadline);
      WETH(wethAddress).deposit.value(ethBought)();
      WETH(wethAddress).transfer(msg.sender, ethBought);
    }
}