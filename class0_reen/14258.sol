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






contract CAToken is BTLToken, Destructible {

    
    string public constant symbol = "testCAT";
    string public constant name = "testCAT";
    uint8 public constant decimals = 18;
    string public constant version = "1.0";

    
    function destroy() public onlyOwner {
        require(mintingFinished);
        super.destroy();
    }

    
    function destroyAndSend(address _recipient) public onlyOwner {
        require(mintingFinished);
        super.destroyAndSend(_recipient);
    }

}








