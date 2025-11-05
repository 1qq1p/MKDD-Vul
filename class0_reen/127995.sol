pragma solidity 0.4.24;

library ECRecovery {

  




  function recover(bytes32 hash, bytes sig) public pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    
    if (sig.length != 65) {
      return (address(0));
    }

    
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

    
    if (v < 27) {
      v += 27;
    }

    
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      return ecrecover(hash, v, r, s);
    }
  }

}

contract Claimable is Ownable {
  address public pendingOwner;

  


  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  



  function transferOwnership(address newOwner) onlyOwner public {
    pendingOwner = newOwner;
  }

  


  function claimOwnership() onlyPendingOwner public {
    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = 0x0;
  }
}
