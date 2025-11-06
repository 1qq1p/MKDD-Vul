pragma solidity ^0.4.23;





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

contract EtheremonAdventureData {
    
    function addLandRevenue(uint _siteId, uint _emontAmount, uint _etherAmount) external;
    function addTokenClaim(uint _tokenId, uint _emontAmount, uint _etherAmount) external;
    
    
    function getLandRevenue(uint _classId) constant public returns(uint _emontAmount, uint _etherAmount);
    function getTokenClaim(uint _tokenId) constant public returns(uint _emontAmount, uint _etherAmount);
}
