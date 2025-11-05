pragma solidity ^0.4.24;







interface IERC165 {

  





  function supportsInterface(bytes4 interfaceId)
    external
    view
    returns (bool);
}







contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {
  
  string internal _name;

  
  string internal _symbol;

  
  mapping(uint256 => string) private _tokenURIs;

  bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;
  






  


  constructor(string name, string symbol) public {
    _name = name;
    _symbol = symbol;

    
    _registerInterface(InterfaceId_ERC721Metadata);
  }

  



  function name() external view returns (string) {
    return _name;
  }

  



  function symbol() external view returns (string) {
    return _symbol;
  }

  




  function tokenURI(uint256 tokenId) public view returns (string) {
    require(_exists(tokenId));
    return _tokenURIs[tokenId];
  }

  





  function _setTokenURI(uint256 tokenId, string uri) internal {
    require(_exists(tokenId));
    _tokenURIs[tokenId] = uri;
  }

  





  function _burn(address owner, uint256 tokenId) internal {
    super._burn(owner, tokenId);

    
    if (bytes(_tokenURIs[tokenId]).length != 0) {
      delete _tokenURIs[tokenId];
    }
  }
}








