pragma solidity ^0.4.11;






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







contract Distributable is Ownable {
  mapping(address => bool) public dealership;
  event Trust(address dealer);
  event Distrust(address dealer);

  modifier onlyDealers() {
    require(dealership[msg.sender]);
    _;
  }

  function trust(address newDealer) public onlyOwner {
    require(newDealer != address(0));
    require(!dealership[newDealer]);
    dealership[newDealer] = true;
    Trust(newDealer);
  }

  function distrust(address dealer) public onlyOwner {
    require(dealership[dealer]);
    dealership[dealer] = false;
    Distrust(dealer);
  }

}

