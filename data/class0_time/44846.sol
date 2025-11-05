

pragma solidity ^0.4.24;








contract Proxy {
  



  function () payable external {
    _fallback();
  }

  


  function _implementation() internal view returns (address);

  





  function _delegate(address implementation) internal {
    assembly {
      
      
      
      calldatacopy(0, 0, calldatasize)

      
      
      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

      
      returndatacopy(0, 0, returndatasize)

      switch result
      
      case 0 { revert(0, returndatasize) }
      default { return(0, returndatasize) }
    }
  }

  




  function _willFallback() internal {
  }

  



  function _fallback() internal {
    _willFallback();
    _delegate(_implementation());
  }
}



pragma solidity ^0.4.24;









library ZOSLibAddress {

  






  function isContract(address account) internal view returns (bool) {
    uint256 size;
    
    
    
    
    
    
    
    assembly { size := extcodesize(account) }
    return size > 0;
  }

}



pragma solidity ^0.4.24;








