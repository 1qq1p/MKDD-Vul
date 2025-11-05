pragma solidity ^0.4.24;







library SafeERC20 {

  using SafeMath for uint256;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    
    
    
    require((value == 0) || (token.allowance(msg.sender, spender) == 0));
    require(token.approve(spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    require(token.approve(spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).sub(value);
    require(token.approve(spender, newAllowance));
  }
}





library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); 
    uint256 c = a / b;
    

    return c;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  



  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}





interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}








contract LILEPriceContract is Crowdsale, Ownable {
  
  uint256 public minimumAllowed = 100000000000000000; 
  uint256 public maximumAllowed = 101000000000000000000; 
  uint256 private _rate;
  
  


  event LILEPriceUpdated(uint256 oldPrice, uint256 newPrice);
  
  constructor (uint256 rate) public {
      _rate = rate;
  }
  
  function updateLILEPrice(uint256 _weiAmount) onlyOwner external {
    require(_weiAmount > 0);
    assert((1 ether) % _weiAmount == 0);
    emit LILEPriceUpdated(_rate, _weiAmount);
    _rate = _weiAmount;
  }
    
  




  function _preValidatePurchase(
    address beneficiary,
    uint256 weiAmount
  )
    internal
    view
  {
    require(weiAmount >= minimumAllowed && weiAmount <= maximumAllowed);
    super._preValidatePurchase(beneficiary, weiAmount);
  }
  
  function rate() public view returns(uint256) {
    return _rate;
  }
  
  




  function _getTokenAmount(uint256 weiAmount)
    internal view returns (uint256)
  {
    uint256 amount = 0;
    
    
    if(weiAmount >= 100000000000000000 && weiAmount < 500000000000000000){
      amount = weiAmount.mul( _rate.add(_rate.mul(9).div(100)) );
    }
    
        else if(weiAmount >= 500000000000000000 && weiAmount < 1000000000000000000) {
      amount = weiAmount.mul( _rate.add(_rate.mul(18).div(100)) );
    } 
    
    else if(weiAmount >= 1000000000000000000 && weiAmount < 3000000000000000000) {
      amount = weiAmount.mul( _rate.add(_rate.mul(39).div(100)) );
    } 
    
    else if(weiAmount >= 3000000000000000000 && weiAmount < 500000000000000000) {
      amount = weiAmount.mul( _rate.add(_rate.mul(61).div(100)) );
    } 
    
    else if (weiAmount >= 500000000000000000 && weiAmount < 101000000000000000000) 
      amount = weiAmount.mul( _rate.add(_rate.mul(81).div(100)) );
    
    else 
      amount = weiAmount.mul( _rate);
    
    
    amount = amount.div(10 ** 10);
    return amount;
  }
  
  


  function getTokenAmount(uint256 weiAmount)
    public view returns (uint256)
  {
    return _getTokenAmount(weiAmount);
  }
  
}







 