pragma solidity ^0.4.24;





interface IERC165 {

  





  function supportsInterface(bytes4 interfaceId)
    external
    view
    returns (bool);
}






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









contract CryptoHeart is ERC721, Ownable {

  function mint(address _to, uint256 tokenId) public onlyOwner {
    _mint(_to, tokenId);
  }

}


