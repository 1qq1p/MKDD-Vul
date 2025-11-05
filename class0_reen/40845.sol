

pragma solidity ^0.4.23;





library AddressUtils {

  






  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    
    
    
    
    
    
    
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

}



pragma solidity ^0.4.23;







contract NokuCustomService is Pausable {
    using AddressUtils for address;

    event LogPricingPlanChanged(address indexed caller, address indexed pricingPlan);

    
    NokuPricingPlan public pricingPlan;

    constructor(address _pricingPlan) internal {
        require(_pricingPlan.isContract(), "_pricingPlan is not contract");

        pricingPlan = NokuPricingPlan(_pricingPlan);
    }

    function setPricingPlan(address _pricingPlan) public onlyOwner {
        require(_pricingPlan.isContract(), "_pricingPlan is not contract");
        require(NokuPricingPlan(_pricingPlan) != pricingPlan, "_pricingPlan equal to current");
        
        pricingPlan = NokuPricingPlan(_pricingPlan);

        emit LogPricingPlanChanged(msg.sender, _pricingPlan);
    }
}



pragma solidity ^0.4.23;






library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    
    
    
    if (a == 0) {
      return 0;
    }

    c = a * b;
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

  


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}



pragma solidity ^0.4.23;






