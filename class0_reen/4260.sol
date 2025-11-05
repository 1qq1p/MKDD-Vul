pragma solidity ^0.4.24;



contract MultiSigTransfer is Ownable {
  string public name = "MultiSigTransfer";
  string public symbol = "MST";
  bool public complete = false;
  bool public denied = false;
  uint32 public quantity;
  address public targetAddress;
  address public requesterAddress;

  






  constructor(
    uint32 _quantity,
    address _targetAddress,
    address _requesterAddress
  ) public {
    quantity = _quantity;
    targetAddress = _targetAddress;
    requesterAddress = _requesterAddress;
  }

  


  function approveTransfer() public onlyOwner {
    require(denied == false, "cannot approve a denied transfer");
    require(complete == false, "cannot approve a complete transfer");
    complete = true;
  }

  


  function denyTransfer() public onlyOwner {
    require(denied == false, "cannot deny a transfer that is already denied");
    denied = true;
  }

  


  function isPending() public view returns (bool) {
    return !complete;
  }
}
