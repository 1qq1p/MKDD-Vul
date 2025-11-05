pragma solidity 0.4.24;





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





contract Owned {

    
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    address public owner;

    
    function Owned() public {owner = msg.sender;}

    
    
    
    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}
