pragma solidity ^0.4.18;






library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}







contract Claimable is Ownable {
    address public pendingOwner;

    


    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner);
        _;
    }

    



    function transferOwnership(address newOwner) public onlyOwner {
        pendingOwner = newOwner;
    }

    


    function claimOwnership() public onlyPendingOwner {
         OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}






