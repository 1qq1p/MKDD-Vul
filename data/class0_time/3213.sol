pragma solidity ^0.4.24;







interface ERC165 {

  





  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);
}







contract ERC721Metadata is ERC721Basic {
  function name() external view returns (string _name);
  function symbol() external view returns (string _symbol);
  function tokenURI(uint256 _tokenId) public view returns (string);
}





