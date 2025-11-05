pragma solidity ^0.4.23;








contract NokuPricingPlan {
    







    function payFee(bytes32 serviceName, uint256 multiplier, address client) public returns(bool paid);

    






    function usageFee(bytes32 serviceName, uint256 multiplier) public constant returns(uint fee);
}






library AddressUtils {

  






  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    
    
    
    
    
    
    assembly { size := extcodesize(addr) }  
    return size > 0;
  }

}






