pragma solidity ^0.4.18;








contract ERC721Enumerable is ERC721Metadata {

    
    bytes4 internal constant INTERFACE_SIGNATURE_ERC721Enumerable =
        bytes4(keccak256("deedByIndex()")) ^
        bytes4(keccak256("countOfOwners()")) ^
        bytes4(keccak256("ownerByIndex(uint256)"));

    function deedByIndex(uint256 _index) external view returns (uint256 _deedId);
    function countOfOwners() external view returns (uint256 _count);
    function ownerByIndex(uint256 _index) external view returns (address _owner);
}
