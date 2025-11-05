pragma solidity 0.4.21;







library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
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



library R {

    struct Rational {
        uint n;  
        uint d;  
    }

}


library Rationals {
    using SafeMath for uint;

    function rmul(uint256 amount, R.Rational memory r) internal pure returns (uint256) {
        return amount.mul(r.n).div(r.d);
    }

}








contract Exchange is Pausable, RBAC {
    using SafeMath for uint256;

    string constant ROLE_ORACLE = "oracle";

    ERC20 baseToken;
    ERC20 dai;  
    address public oracle;
    R.Rational public ethRate;
    R.Rational public daiRate;

    event TradeETH(uint256 amountETH, uint256 amountBaseToken);
    event TradeDAI(uint256 amountDAI, uint256 amountBaseToken);
    event RateUpdatedETH(uint256 n, uint256 d);
    event RateUpdatedDAI(uint256 n, uint256 d);
    event OracleSet(address oracle);

    










    function Exchange(
        address _baseToken,
        address _dai,
        address _oracle,
        uint256 _ethRateN,
        uint256 _ethRateD,
        uint256 _daiRateN,
        uint256 _daiRateD
    ) public {
        baseToken = ERC20(_baseToken);
        dai = ERC20(_dai);
        addRole(_oracle, ROLE_ORACLE);
        oracle = _oracle;
        ethRate = R.Rational(_ethRateN, _ethRateD);
        daiRate = R.Rational(_daiRateN, _daiRateD);
    }

    






    function tradeETH(uint256 expectedAmountBaseToken) public whenNotPaused() payable {
        uint256 amountBaseToken = calculateAmountForETH(msg.value);
        require(amountBaseToken == expectedAmountBaseToken);
        require(baseToken.transfer(msg.sender, amountBaseToken));
        emit TradeETH(msg.value, amountBaseToken);
    }

    








    function tradeDAI(uint256 amountDAI, uint256 expectedAmountBaseToken) public whenNotPaused() {
        uint256 amountBaseToken = calculateAmountForDAI(amountDAI);
        require(amountBaseToken == expectedAmountBaseToken);
        require(dai.transferFrom(msg.sender, address(this), amountDAI));
        require(baseToken.transfer(msg.sender, amountBaseToken));
        emit TradeDAI(amountDAI, amountBaseToken);
    }

    




    function calculateAmountForETH(uint256 amountETH) public view returns (uint256) {
        return Rationals.rmul(amountETH, ethRate);
    }

    




    function calculateAmountForDAI(uint256 amountDAI) public view returns (uint256) {
        return Rationals.rmul(amountDAI, daiRate);
    }

    





    function setETHRate(uint256 n, uint256 d) external onlyRole(ROLE_ORACLE) {
        ethRate = R.Rational(n, d);
        emit RateUpdatedETH(n, d);
    }

    





    function setDAIRate(uint256 n, uint256 d) external onlyRole(ROLE_ORACLE) {
        daiRate = R.Rational(n, d);
        emit RateUpdatedDAI(n, d);
    }

    





    function withdrawERC20s(address token, uint256 amount) external onlyOwner {
        ERC20 erc20 = ERC20(token);
        require(erc20.transfer(owner, amount));
    }

    




    function setOracle(address _oracle) external onlyOwner {
        removeRole(oracle, ROLE_ORACLE);
        addRole(_oracle, ROLE_ORACLE);
        oracle = _oracle;
        emit OracleSet(_oracle);
    }

    
    function withdrawEther() external onlyOwner {
        owner.transfer(address(this).balance);
    }

}