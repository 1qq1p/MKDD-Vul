pragma solidity ^0.4.21;





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






contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    


    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    



    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}




