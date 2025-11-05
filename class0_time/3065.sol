pragma solidity ^0.4.24;







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










contract PlazaCrowdsale is CappedCrowdsale, FinalizableCrowdsale, MintedCrowdsale, WhitelistedCrowdsale, TieredPriceCrowdsale {
    constructor(
        uint256 openingTime,
        uint256 closingTime,
        uint256 rate,
        address wallet,
        uint256 cap,
        ERC20Mintable token,
        uint256 openingTimeTier4, 
        uint256 openingTimeTier3, 
        uint256 openingTimeTier2,
        uint256 invCap
    )
    public
    Crowdsale(rate, wallet, token)
    CappedCrowdsale(cap)
    WhitelistedCrowdsale(invCap)
    TimedCrowdsale(openingTime, closingTime)
    TieredPriceCrowdsale(rate, openingTimeTier2, openingTimeTier3, openingTimeTier4)
    {}

}