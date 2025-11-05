pragma solidity ^0.4.24;



library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256){
    if(a==0){
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256){
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256){
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}




library AddressUtils {
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    assembly { size := extcodesize(addr) }
    return size > 0;
  }
}



interface ERC165 {
  function supportsInterface(bytes4 _interfaceId) external view returns (bool);
}



contract ERC721TokenReceiver {
  bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;
  bytes4 retval;
  bool reverts;

  constructor(bytes4 _retval, bool _reverts) public {
    retval = _retval;
    reverts = _reverts;
  }

  event Received(address _operator, address _from, uint256 _tokenId, bytes _data, uint256 _gas );

  function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data ) public returns(bytes4) {
    require(!reverts);
    emit Received(
      _operator,
      _from,
      _tokenId,
      _data,
      gasleft()
    );
    return retval;
  }
}


