pragma solidity 0.5.0;






contract TransferFilter is Ownable {
  bool public isTransferable;
  mapping( address => bool ) public mapAddressPass;
  mapping( address => bool ) public mapAddressBlock;

  event LogFilterPass(address indexed target, bool status);
  event LogFilterBlock(address indexed target, bool status);

  
  modifier checkTokenTransfer(address source) {
      if (isTransferable == true) {
          require(mapAddressBlock[source] == false);
      }
      else {
          require(mapAddressPass[source] == true);
      }
      _;
  }

  constructor() public {
      isTransferable = true;
  }

  function setTransferable(bool status) public onlyOwner {
      isTransferable = status;
  }

  function isInPassFilter(address user) public view returns (bool) {
    return mapAddressPass[user];
  }

  function isInBlockFilter(address user) public view returns (bool) {
    return mapAddressBlock[user];
  }

  function addressToPass(address[] memory target, bool status)
  public
  onlyOwner
  {
    for( uint i = 0 ; i < target.length ; i++ ) {
        address targetAddress = target[i];
        bool old = mapAddressPass[targetAddress];
        if (old != status) {
            if (status == true) {
                mapAddressPass[targetAddress] = true;
                emit LogFilterPass(targetAddress, true);
            }
            else {
                delete mapAddressPass[targetAddress];
                emit LogFilterPass(targetAddress, false);
            }
        }
    }
  }

  function addressToBlock(address[] memory target, bool status)
  public
  onlyOwner
  {
      for( uint i = 0 ; i < target.length ; i++ ) {
          address targetAddress = target[i];
          bool old = mapAddressBlock[targetAddress];
          if (old != status) {
              if (status == true) {
                  mapAddressBlock[targetAddress] = true;
                  emit LogFilterBlock(targetAddress, true);
              }
              else {
                  delete mapAddressBlock[targetAddress];
                  emit LogFilterBlock(targetAddress, false);
              }
          }
      }
  }
}





