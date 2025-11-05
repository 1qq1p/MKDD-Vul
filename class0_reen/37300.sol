pragma solidity ^0.4.18;






library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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






contract AccessMint is Claimable {

  
  mapping(address => bool) private mintAccess;

  
  modifier onlyAccessMint {
    require(msg.sender == owner || mintAccess[msg.sender] == true);
    _;
  }

  
  function grantAccessMint(address _address)
    onlyOwner
    public
  {
    mintAccess[_address] = true;
  }

  
  function revokeAccessMint(address _address)
    onlyOwner
    public
  {
    mintAccess[_address] = false;
  }

}





