pragma solidity ^0.4.22;






contract Destructible is Ownable {
  


  function destroy() public onlyOwner {
    selfdestruct(owner());
  }

  function destroyAndSend(address _recipient) public onlyOwner {
    selfdestruct(_recipient);
  }
}





interface IERC165 {

  





  function supportsInterface(bytes4 interfaceId)
    external
    view
    returns (bool);
}





