pragma solidity ^0.4.11;

library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    
    uint c = a / b;
    
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}
contract ERP is BasicToken,Ownable {

   using SafeMath for uint256;
   
   string public constant name = "ERP";
   string public constant symbol = "ERP";
   uint256 public constant decimals = 18;  
   address public ethStore = 0xDcbFE8d41D4559b3EAD3179fa7Bb3ad77EaDa564;
   uint256 public REMAINING_SUPPLY = 100000000000  * (10 ** uint256(decimals));
   event Debug(string message, address addr, uint256 number);
   event Message(string message);
    string buyMessage;
  
  address wallet;
   


    function ERP(address _wallet) public {
        owner = msg.sender;
        totalSupply = REMAINING_SUPPLY;
        wallet = _wallet;
        tokenBalances[wallet] = totalSupply;   
    }
    
     function mint(address from, address to, uint256 tokenAmount) public onlyOwner {
      require(tokenBalances[from] >= tokenAmount);               
      tokenBalances[to] = tokenBalances[to].add(tokenAmount);                  
      tokenBalances[from] = tokenBalances[from].sub(tokenAmount);                        
      REMAINING_SUPPLY = tokenBalances[wallet];
      Transfer(from, to, tokenAmount); 
    }
    
    function getTokenBalance(address user) public view returns (uint256 balance) {
        balance = tokenBalances[user]; 
        return balance;
    }
}