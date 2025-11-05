






pragma solidity 0.5.2;









contract ExitHandlerProxy is AdminableProxy {

  constructor(ExitHandler _implementation, bytes memory _data) 
    AdminableProxy(address(_implementation), _data) public payable {
  }

}