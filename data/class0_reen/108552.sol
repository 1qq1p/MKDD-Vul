pragma solidity 0.4.24;






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





contract DaigouCoin is BurnableToken {
     string public name ;
     string public symbol ;
     uint8 public decimals = 18 ;
     
     


     function ()public payable {
         revert();
     }
     
     


     constructor(address wallet) public 
     {
         owner = wallet;
         totalSupply = uint(1000000000).mul( 10 ** uint256(decimals)); 
         name = "Daigou Coin";
         symbol = "DGR";
         balances[wallet] = totalSupply;
         
         
         emit Transfer(address(0), msg.sender, totalSupply);
     }
     
     


    function getTokenDetail() public view returns (string, string, uint256) {
	    return (name, symbol, totalSupply);
    }
 }