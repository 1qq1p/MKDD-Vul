pragma solidity ^0.4.17;













contract Owned {

    address public owner;
    address public newOwner;

    event OwnerChanged(address indexed _newOwner);


    function Owned() public {
        owner = msg.sender;
    }


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    function transferOwnership(address _newOwner) public onlyOwner returns (bool) {
        require(_newOwner != address(0));
        require(_newOwner != owner);

        newOwner = _newOwner;

        return true;
    }


    function acceptOwnership() public returns (bool) {
        require(msg.sender == newOwner);

        owner = msg.sender;

        OwnerChanged(msg.sender);

        return true;
    }
}


pragma solidity ^0.4.17;






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



pragma solidity ^0.4.17;















