pragma solidity ^0.4.21;


contract AFDTICO is Ownable {
  using SafeERC20 for ERC20Basic;
  
  ERC20Basic public token;
  using SafeMath for uint256;
  
  mapping(address => uint) bal;  
  mapping(address => uint) token_balance; 
  
  uint256 public RATE = 2188; 
  uint256 public minimum = 10000000000000000;   

  address public constant FAVOREE = 0x57f3495D0eb2257F1B0Dbbc77a8A49E4AcAC82f5; 
  uint256 public raisedAmount = 0; 
  
  



  event BoughtTokens(address indexed to, uint256 value, uint256 tokens);

  constructor(ERC20Basic _token) public {
      token = _token;
  }

  


  function () public payable {

    buyTokens();
  }

  



  function buyTokens() public payable {
    require(msg.value >= minimum);
    uint256 weiAmount = msg.value; 
    uint256 tokens = msg.value.mul(RATE).div(10**10);  
    
    uint256 balance = token.balanceOf(this);     
    if (tokens > balance){                       
        msg.sender.transfer(weiAmount);
        
    }
    
    else{
        if (bal[msg.sender] == 0){
            token.transfer(msg.sender, tokens); 
            
            
            emit BoughtTokens(msg.sender, msg.value, tokens);
            
            token_balance[msg.sender] = tokens;
            bal[msg.sender] = msg.value;
            
            raisedAmount = raisedAmount.add(weiAmount);
            
        }
         else{
             uint256 b = bal[msg.sender];
             uint256 c = token_balance[msg.sender];
             token.transfer(msg.sender, tokens); 
             emit BoughtTokens(msg.sender, msg.value, tokens); 
             
             bal[msg.sender] = b.add(msg.value);
             token_balance[msg.sender] = c.add(tokens);
             
             raisedAmount = raisedAmount.add(weiAmount);
             
             
         }
    }
 }

  



  function tokensAvailable() public constant returns (uint256) {
    return token.balanceOf(this);
  }

  function ratio(uint256 _RATE) onlyOwner public {
      RATE = _RATE;
  }
  
  function withdrawals() onlyOwner public {
      FAVOREE.transfer(raisedAmount);
      raisedAmount = 0;
  }
  
  function adjust_eth(uint256 _minimum) onlyOwner  public {
      minimum = _minimum;
  }
  



  function destroy() onlyOwner public {
    
    uint256 balance = token.balanceOf(this);
    assert(balance > 0);
    token.transfer(FAVOREE, balance);
    
    selfdestruct(FAVOREE); 
  }
}