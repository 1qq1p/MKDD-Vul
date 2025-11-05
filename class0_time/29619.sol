pragma solidity ^0.4.18;
contract Targeted is Owned {
    ERC721 public target;
    function changeTarget (address newTarget) public onlyOwner {
        target = ERC721(newTarget);
    }
}