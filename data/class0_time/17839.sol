pragma solidity ^0.4.13;

contract Destructible is Ownable {

  function Destructible() payable { } 

  


  function destroy() public onlyOwner {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) public onlyOwner {
    selfdestruct(_recipient);
  }
}
