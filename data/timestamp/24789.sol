pragma solidity ^0.4.24;






contract ERC20Burnable is ERC20 {
  



  function burn(uint256 value) public {
    _burn(msg.sender, value);
  }
  




  function burnFrom(address from, uint256 value) public {
    _burnFrom(from, value);
  }
  



  function _burn(address who, uint256 value) internal {
    super._burn(who, value);
  }
}


pragma solidity 0.4.24;