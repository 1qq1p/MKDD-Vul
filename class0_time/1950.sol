pragma solidity ^0.4.24;






























library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  


  function add(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = true;
  }

  


  function remove(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = false;
  }

  



  function check(Role storage _role, address _addr)
    internal
    view
  {
    require(has(_role, _addr));
  }

  



  function has(Role storage _role, address _addr)
    internal
    view
    returns (bool)
  {
    return _role.bearer[_addr];
  }
}












contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}






library SafeMath {
  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  


  function mul(uint256 a, uint256 b) 
      internal 
      pure 
      returns (uint256 c) 
  {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    require(c / a == b, "SafeMath mul failed");
    return c;
  }

  


  function sub(uint256 a, uint256 b)
      internal
      pure
      returns (uint256) 
  {
    require(b <= a, "SafeMath sub failed");
    return a - b;
  }

  


  function add(uint256 a, uint256 b)
      internal
      pure
      returns (uint256 c) 
  {
    c = a + b;
    require(c >= a, "SafeMath add failed");
    return c;
  }
  
  


  function sqrt(uint256 x)
      internal
      pure
      returns (uint256 y) 
  {
    uint256 z = ((add(x,1)) / 2);
    y = x;
    while (z < y) 
    {
      y = z;
      z = ((add((x / z),z)) / 2);
    }
  }
  
  


  function sq(uint256 x)
      internal
      pure
      returns (uint256)
  {
    return (mul(x,x));
  }
  
  


  function pwr(uint256 x, uint256 y)
      internal 
      pure 
      returns (uint256)
  {
    if (x==0)
        return (0);
    else if (y==0)
        return (1);
    else 
    {
      uint256 z = x;
      for (uint256 i=1; i < y; i++)
        z = mul(z,x);
      return (z);
    }
  }
}







interface INFTsCrowdsale {

  function getAuction(uint256 tokenId) external view
  returns (
    bytes32,
    address,
    uint256,
    uint256,
    uint256,
    uint256
  );

  function isOnAuction(uint256 tokenId) external view returns (bool);

  function isOnPreAuction(uint256 tokenId) external view returns (bool);

  function newAuction(uint128 price, uint256 tokenId, uint256 startAt, uint256 endAt) external;

  function batchNewAuctions(uint128[] prices, uint256[] tokenIds, uint256[] startAts, uint256[] endAts) external;

  function payByEth (uint256 tokenId) external payable; 

  function payByErc20 (uint256 tokenId) external;

  function cancelAuction (uint256 tokenId) external;

  function batchCancelAuctions (uint256[] tokenIds) external;
  
  

  event NewAuction (
    bytes32 id,
    address indexed seller,
    uint256 price,
    uint256 startAt,
    uint256 endAt,
    uint256 indexed tokenId
  );

  event PayByEth (
    bytes32 id,
    address indexed seller,
    address indexed buyer,
    uint256 price,
    uint256 endAt,
    uint256 indexed tokenId
  );

  event PayByErc20 (
    bytes32 id,
    address indexed seller,
    address indexed buyer, 
    uint256 price,
    uint256 endAt,
    uint256 indexed tokenId
  );

  event CancelAuction (
    bytes32 id,
    address indexed seller,
    uint256 indexed tokenId
  );

}


