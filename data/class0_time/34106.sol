pragma solidity ^0.4.24;









contract Members is Ownable {

  mapping(address => bool) public members; 

  modifier onlyMembers() {
    require(isValidMember(msg.sender));
    _;
  }

  
  function isValidMember(address _member) public view returns(bool) {
    return members[_member];
  }

  
  function addMember(address _member) public onlyOwner {
    members[_member] = true;
  }

  
  function removeMember(address _member) public onlyOwner {
    delete members[_member];
  }
}

