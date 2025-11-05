pragma solidity ^0.4.24;








contract RBACMintableToken is MintableToken, RBAC {
  


  string public constant ROLE_MINTER = "minter";

  


  modifier hasMintPermission() {
    checkRole(msg.sender, ROLE_MINTER);
    _;
  }

  



  function addMinter(address _minter) public onlyOwner {
    addRole(_minter, ROLE_MINTER);
  }

  



  function removeMinter(address _minter) public onlyOwner {
    removeRole(_minter, ROLE_MINTER);
  }
}






