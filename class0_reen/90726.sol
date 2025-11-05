pragma solidity ^0.4.18;








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






contract KStarCoinSale is MultiOwnable {
    using SafeMath for uint256;
    
    eICOLevel public level;
    uint256 public rate;
    uint256 public minWei;

    function checkValidLevel(eICOLevel _level) public pure returns (bool) {
        return (_level == eICOLevel.C_ICO_PRESALE || _level == eICOLevel.C_ICO_ONSALE || _level == eICOLevel.C_ICO_END);
    }

    modifier onSale() {
        require(level != eICOLevel.C_ICO_END);
        _;
    }
    
    enum eICOLevel { C_ICO_PRESALE, C_ICO_ONSALE, C_ICO_END }
    
    Coin public coin;
    address public wallet;

    
    function KStarCoinSale(Coin _coin, address _wallet) public {
        require(_coin != address(0));
        require(_wallet != address(0));
        
        coin= _coin;
        wallet= _wallet;

        updateICOVars(  eICOLevel.C_ICO_PRESALE,
                        3750,       
                        1e5 szabo); 
    }
    
    
    function updateICOVars(eICOLevel _level, uint256 _rate, uint256 _minWei) onlyOwner public returns (bool) {
        require(checkValidLevel(_level));
        require(_rate != 0);
        require(_minWei >= 1 szabo);
        
        level= _level;
        rate= _rate;
        minWei= _minWei;
        
        ICOVarsChange(level, rate, minWei);
        return true;
    }
    
    function () external payable {
        buyCoin(msg.sender);
    }
    
    function buyCoin(address beneficiary) onSale public payable {
        require(beneficiary != address(0));
        require(msg.value >= minWei);

        
        uint256 coins= getCoinAmount(msg.value);
        
        
        coin.sell(beneficiary, coins, "");
        
        forwardFunds();
    }

    function getCoinAmount(uint256 weiAmount) internal view returns(uint256) {
        return weiAmount.mul(rate);
    }
  
    
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }
    
    event ICOVarsChange(eICOLevel level, uint256 rate, uint256 minWei);
}