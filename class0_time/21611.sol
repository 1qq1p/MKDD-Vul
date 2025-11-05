pragma solidity ^0.4.24;






contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}




library AddressUtils {

  






  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    
    
    
    
    
    
    
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

}





