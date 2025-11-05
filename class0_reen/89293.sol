

pragma solidity ^0.5.0;










interface IERC165 {
    







    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}



pragma solidity ^0.5.0;





contract SuperPlayerGachaWithRecommendReward  is Ownable  {

  mapping(uint=> address) recommendRecord;


  function addRecommend(string memory key,address payable to ) public  onlyOwner{
     uint256 uintkey = uint256(keccak256(abi.encodePacked(bytes(key))));
     recommendRecord[uintkey] = to;
  }


  function getRecommendAddress( string memory key ) public view returns(address) {
    return _getRecommendAddress(key);
  }

  function _getRecommendAddress( string memory key ) internal view returns(address) {
     uint256 uintkey = uint256(keccak256(abi.encodePacked(bytes(key))));
     return recommendRecord[uintkey];
  }



}
