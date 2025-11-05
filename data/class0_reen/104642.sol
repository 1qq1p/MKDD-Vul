pragma solidity 0.4.19;






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






contract KOANToken is BurnableToken {
     string public name ;
     string public symbol ;
     uint8 public decimals = 9 ;
     
     


     function ()public payable {
         revert();
     }
     
     





     function KOANToken(
            uint256 initialSupply,
            string tokenName,
            string tokenSymbol
         ) public {
         totalSupply = initialSupply.mul( 10 ** uint256(decimals)); 
         name = tokenName;
         symbol = tokenSymbol;
         balances[msg.sender] = totalSupply;
         
         
         Transfer(address(0), msg.sender, totalSupply);
     }
     
     







     function multiSend(address[]dests, uint[]values)public{
        require(dests.length==values.length);
        uint256 i = 0;
        while (i < dests.length) {
           transfer(dests[i], values[i]);
           i += 1;
        }
     }
     
     


    function getTokenDetail() public view returns (string, string, uint256) {
	    return (name, symbol, totalSupply);
    }
 }