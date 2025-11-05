pragma solidity ^0.4.24;





interface IERC165 {

  





  function supportsInterface(bytes4 interfaceId)
    external
    view
    returns (bool);
}





contract IERC721Enumerable is IERC721 {
  function totalSupply() public view returns (uint256);
  function tokenOfOwnerByIndex(
    address owner,
    uint256 index
  )
    public
    view
    returns (uint256 tokenId);

  function tokenByIndex(uint256 index) public view returns (uint256);
}





