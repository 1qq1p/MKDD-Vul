

pragma solidity ^0.5.0;










interface IERC165 {
    







    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}



pragma solidity ^0.5.0;





contract EquipGeneratorWhitelist is Ownable {
  mapping(address => string) public whitelist;
  mapping(string => address)  cat2address;

  event WhitelistedAddressAdded(address addr,string category);
  event WhitelistedAddressRemoved(address addr);

  


  modifier canGenerate() {
    
    require(bytes(whitelist[msg.sender]).length >0 );
    _;
  }

  




  function addAddressToWhitelist(address addr,string memory category) onlyOwner internal returns(bool success) {
    require( bytes(category).length > 0 );
    if (bytes(whitelist[addr]).length == 0) {
      require( cat2address[category] == address(0));
      whitelist[addr] = category;
      emit WhitelistedAddressAdded(addr,category);
      success = true;
    }
  }


  





  function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
    string storage category = whitelist[addr];
    if (bytes(category).length != 0) {
      delete cat2address[category] ;
      delete whitelist[addr]  ;
      emit WhitelistedAddressRemoved(addr);
      success = true;
    }
  }



}


