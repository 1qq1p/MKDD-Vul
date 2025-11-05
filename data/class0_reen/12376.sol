





















pragma solidity ^0.4.15;

contract ERC20Token is Owned, DSMath {
  
  bool public constant isEIP20Token = true; 
  uint public totalSupply;     
  bool public saleInProgressB; 

  mapping(address => uint) internal iTokensOwnedM;                 
  mapping(address => mapping (address => uint)) private pAllowedM; 

  
  
  
  
  event Transfer(address indexed src, address indexed dst, uint wad);

  
  
  event Approval(address indexed Sender, address indexed Spender, uint Wad);

  
  
  
  
  
  
  function balanceOf(address guy) public constant returns (uint) {
    return iTokensOwnedM[guy];
  }

  
  
  function allowance(address guy, address spender) public constant returns (uint) {
    return pAllowedM[guy][spender];
  }

  
  
  modifier IsTransferOK(address src, address dst, uint wad) {
    require(!saleInProgressB          
         && !pausedB                  
         && iTokensOwnedM[src] >= wad 
      
         && dst != src                
         && dst != address(this)      
         && dst != ownerA);           
    _;
  }

  
  
  
  
  
  function transfer(address dst, uint wad) IsTransferOK(msg.sender, dst, wad) returns (bool) {
    iTokensOwnedM[msg.sender] -= wad; 
    iTokensOwnedM[dst] = add(iTokensOwnedM[dst], wad);
    Transfer(msg.sender, dst, wad);
    return true;
  }

  
  
  
  
  
  function transferFrom(address src, address dst, uint wad) IsTransferOK(src, dst, wad) returns (bool) {
    require(pAllowedM[src][msg.sender] >= wad); 
    iTokensOwnedM[src]         -= wad; 
    pAllowedM[src][msg.sender] -= wad; 
    iTokensOwnedM[dst] = add(iTokensOwnedM[dst], wad);
    Transfer(src, dst, wad);
    return true;
  }

  
  
  
  
  function approve(address spender, uint wad) IsActive returns (bool) {
    
    
    
    
    
    
    pAllowedM[msg.sender][spender] = wad;
    Approval(msg.sender, spender, wad);
    return true;
  }
} 










