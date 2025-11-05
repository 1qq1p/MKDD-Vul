pragma solidity ^0.4.13;





library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}






contract Certifier {
	event Confirmed(address indexed who);
	event Revoked(address indexed who);
	function certified(address) public constant returns (bool);
	function get(address, string) public constant returns (bytes32);
	function getAddress(address, string) public constant returns (address);
	function getUint(address, string) public constant returns (uint);
}




