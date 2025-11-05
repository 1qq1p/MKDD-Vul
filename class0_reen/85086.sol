pragma solidity ^0.4.24;





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





interface IERC165 {

  





  function supportsInterface(bytes4 interfaceId)
    external
    view
    returns (bool);
}





contract ERC721MetadataMintable is ERC721, ERC721Metadata, MinterRole {
  






  function mintWithTokenURI(
    address to,
    uint256 tokenId,
    string tokenURI
  )
    public
    onlyMinter
    returns (bool)
  {
    
    _mint(to, tokenId);
    _setTokenURI(tokenId, tokenURI);
    return true;
  }
}






