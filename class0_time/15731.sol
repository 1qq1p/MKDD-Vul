pragma solidity ^0.4.19;


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0 || b == 0){
        return 0;
    }
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




contract Ownable {

  address public owner;

  address public newOwner;

  address public techSupport;

  address public newTechSupport;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier onlyTechSupport() {
    require(msg.sender == techSupport);
    _;
  }

  function Ownable() public {
    owner = msg.sender;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    newOwner = _newOwner;
  }

  function acceptOwnership() public {
    if (msg.sender == newOwner) {
      owner = newOwner;
    }
  }

  function transferTechSupport (address _newSupport) public{
    require (msg.sender == owner || msg.sender == techSupport);
    newTechSupport = _newSupport;
  }

  function acceptSupport() public{
    if(msg.sender == newTechSupport){
      techSupport = newTechSupport;
    }
  }
}



