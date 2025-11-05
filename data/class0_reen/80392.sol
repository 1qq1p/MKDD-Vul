

pragma solidity 0.5.00;

library Strings {
  
  
  function Concatenate(string memory a, string memory b) public pure returns (string memory concatenatedString) {
    bytes memory bytesA = bytes(a);
    bytes memory bytesB = bytes(b);
    string memory concatenatedAB = new string(bytesA.length + bytesB.length);
    bytes memory bytesAB = bytes(concatenatedAB);
    uint concatendatedIndex = 0;
    uint index = 0;
    for (index = 0; index < bytesA.length; index++) {
      bytesAB[concatendatedIndex++] = bytesA[index];
    }
    for (index = 0; index < bytesB.length; index++) {
      bytesAB[concatendatedIndex++] = bytesB[index];
    }
      
    return string(bytesAB);
  }

  function UintToString(uint value) public pure returns (string memory uintAsString) {
    uint tempValue = value;
    
    if (tempValue == 0) {
      return "0";
    }
    uint j = tempValue;
    uint length;
    while (j != 0) {
      length++;
      j /= 10;
    }
    bytes memory byteString = new bytes(length);
    uint index = length - 1;
    while (tempValue != 0) {
      byteString[index--] = byte(uint8(48 + tempValue % 10));
      tempValue /= 10;
    }
    return string(byteString);
  }
}



pragma solidity ^0.5.0;





interface IERC165 {
    





    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}



pragma solidity ^0.5.0;






contract IERC721Enumerable is IERC721 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) public view returns (uint256);
}



pragma solidity ^0.5.0;







