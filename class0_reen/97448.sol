pragma solidity ^0.4.16;

























library SafeMath3 {

  function mul(uint a, uint b) internal pure returns (uint c) {
    c = a * b;
    assert(a == 0 || c / a == b);
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint c) {
    c = a + b;
    assert(c >= a);
  }

}








contract Owned {

  address public owner;
  address public newOwner;

  

  event OwnershipTransferProposed(address indexed _from, address indexed _to);
  event OwnershipTransferred(address indexed _from, address indexed _to);

  

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  

  function Owned() public {
    owner = msg.sender;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != owner);
    require(_newOwner != address(0x0));
    OwnershipTransferProposed(owner, _newOwner);
    newOwner = _newOwner;
  }

  function acceptOwnership() public {
    require(msg.sender == newOwner);
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}











