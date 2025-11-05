pragma solidity ^0.4.11;

contract Whizz is StandardToken,Ownable{
      
      
      string public constant name = "Whizz Coin";
      string public constant symbol = "WHZ";
      uint8 public constant decimals = 3; 
      
    
    
      uint256 public constant maxTokens = 67500000*1000; 
      
      uint256 public constant otherSupply = maxTokens*592/1000;
      uint256 _initialSupply = otherSupply;
      uint256 public constant token_price = 600*10**3; 
      uint public constant ico_start = 1507221000;
      uint public constant ico_finish = 1514851200; 
      uint public constant minValue = 1/10*10**18;
      address public wallet = 0x5F217D83784192d397039Ed6E30e796bFB91B9c4;
      
      
      
      uint256 public constant weicap = 13500*10**18;
      uint256 public weiRaised;
      
      
      
      using SafeMath for uint;      
      
      
 
      function Whizz() {
          balances[owner] = otherSupply;    
      }
      
      
      function() payable {        
          tokens_buy();        
      }
      
      
      function totalSupply() constant returns (uint256 totalSupply) {
          totalSupply = _initialSupply;
      }
   
      
            
      function withdraw() onlyOwner returns (bool result) {
          wallet.transfer(this.balance);
          return true;
      }
   
     
 
      

      
            
      function tokens_buy() payable returns (bool) { 

        if((now < ico_start)||(now > ico_finish)) throw;        
        if(_initialSupply >= maxTokens) throw;
        if(!(msg.value >= token_price)) throw;
        if(!(msg.value >= minValue)) throw;

        uint tokens_buy = ((msg.value*token_price)/10**18);
        
        weiRaised = weiRaised.add(msg.value);

        if(!(tokens_buy > 0)) throw;        

        uint tnow = now;

        if((ico_start + 86400*0 <= tnow)&&(tnow <= ico_start + 86400*28)&&(weiRaised <= weicap)){
          tokens_buy = tokens_buy*120/100;
        } 
        
              
        if(_initialSupply.add(tokens_buy) > maxTokens) throw;
        _initialSupply = _initialSupply.add(tokens_buy);
        balances[msg.sender] = balances[msg.sender].add(tokens_buy);        

      }

      
 }
 

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