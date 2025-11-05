

pragma solidity ^0.4.24;







contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  



  constructor() public {
    owner = msg.sender;
  }

  


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  





  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  



  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  



  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}



pragma solidity ^0.4.24;


interface RegulatorServiceI {
  function check(address _token, address _spender, address _from, address _to, uint256 _amount) external returns (uint8);
  function participants(address _token, address participant) external view returns (uint8);
  function messageForReason(uint8 reason) external view returns (string);
}

interface RegulatedTokenERC1404I {
  function _service() external view returns (RegulatorServiceI);
}
