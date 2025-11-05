pragma solidity ^0.4.8;



































contract ICO is ERC20,usingOraclize

{
 
 address[] public addresses ;  

  	
    string public constant name = "ROC";
  
  	
    string public constant symbol = "ROC"; 
    uint8 public constant decimals = 10;  
    
      mapping(address => address) public userStructs;


    bytes32 myid_;
    
    mapping(bytes32=>bytes32) myidList;
    
      uint public totalSupply = 5000000 *10000000000 ;  
      
       mapping(address => uint) balances;

      mapping (address => mapping (address => uint)) allowed;
      
      address owner;
      
      
      uint one_ether_usd_price;
      
        enum State {created , gotapidata,wait}
          State state;
          
          uint256 ether_profit;
      
      uint256 profit_per_token;
      
      uint256 holder_token_balance;
      
      uint256 holder_profit;
      
       event Message(uint256 holder_profit);

      
        
    modifier onlyOwner() {
       if (msg.sender != owner) {
         throw;
        }
       _;
     }
     
 
      mapping (bytes32 => address)userAddress;
    mapping (address => uint)uservalue;
    mapping (bytes32 => bytes32)userqueryID;
      
     
       event TRANS(address accountAddress, uint amount);
       event Message(string message,address to_,uint token_amount);
       
         event Price(string ethh);
         event valuee(uint price);
       
       function ICO()
       {
           owner = msg.sender;
           balances[owner] = totalSupply;
          
       }

         
       function() payable {
           
           
            TRANS(msg.sender, msg.value); 
            
            if(msg.sender != owner)
            {
                
          
   
      bytes32 ID = oraclize_query("URL","json(https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD).USD");
   
             
              userAddress[ID]=msg.sender;
              uservalue[msg.sender]=msg.value;
              userqueryID[ID]=ID;
            }
            
            else if(msg.sender ==owner){
                
                  ether_profit = msg.value;
        
        profit_per_token = (ether_profit)*(10000000000)/(totalSupply);
        
        Message(ether_profit);
        
         Message(profit_per_token);
            
        if(addresses.length >0)
        {
             for (uint i = 0; i < addresses.length; i++) {

                if(addresses[i] !=owner)
                {
                 request_dividend(addresses[i]);
                }

               }
                }
                
            }
            
            
           
       }
       
      function __callback(bytes32 myid, string result) {
    if (msg.sender != oraclize_cbAddress()) {
      
      throw;
    }
    
    if(userqueryID[myid]== myid)
    {

      
       one_ether_usd_price = stringToUint(result);
    
    valuee(one_ether_usd_price);
    
    if(one_ether_usd_price<1000)
    {
        one_ether_usd_price = one_ether_usd_price*100;
    }
    else if(one_ether_usd_price<10000)
    {
        one_ether_usd_price = one_ether_usd_price*10;
    }
    
    valuee(one_ether_usd_price);
            
            uint no_of_token = (one_ether_usd_price*uservalue[userAddress[myid]])/(275*10000000000000000*100); 
            
                 
            balances[owner] -= (no_of_token*10000000000);
            balances[userAddress[myid]] += (no_of_token*10000000000);
             Transfer(owner, userAddress[myid] , no_of_token);
             
              check_array_add(userAddress[myid]);
             
  
    }
        

 }
 
      function request_dividend(address token_holder) payable
    {
        
        holder_token_balance = balanceOf(token_holder)/10000000000;
        
        Message(holder_token_balance);
        
        holder_profit = holder_token_balance * profit_per_token;
        
        Message(holder_profit);
        
         Transfer(owner, token_holder , (holder_profit/10**18)); 
        
    
        token_holder.send(holder_profit);   
        
    }
  
     function balanceOf(address sender) constant returns (uint256 balance) {
      
          return balances[sender];
      }
      
       
      function transfer(address _to, uint256 _amount) returns (bool success) {
          if (balances[msg.sender] >= _amount 
              && _amount > 0
              && balances[_to] + _amount > balances[_to]) {
              balances[msg.sender] -= _amount;
              balances[_to] += _amount;
              Transfer(msg.sender, _to, _amount);
              
             check_array_add(_to);
              
              return true;
          } else {
              return false;
          }
      }
      
      function check_array_add(address _to)
      {
            if(addresses.length >0)
              {
                 if(userStructs[_to] != _to)
              {
                   userStructs[_to]= _to;
                    addresses.push(_to);
              }
              }
              else
              {
                   userStructs[_to]= _to;
                   addresses.push(_to);
              }
      }
      
      
            
      
      
      
      
      
      
      function transferFrom(
          address _from,
          address _to,
          uint256 _amount
     ) returns (bool success) {
         if (balances[_from] >= _amount
             && allowed[_from][msg.sender] >= _amount
             && _amount > 0
             && balances[_to] + _amount > balances[_to]) {
             balances[_from] -= _amount;
             allowed[_from][msg.sender] -= _amount;
             balances[_to] += _amount;
             Transfer(_from, _to, _amount);
             return true;
         } else {
             return false;
         }
     }
     
         
     
     function approve(address _spender, uint256 _amount) returns (bool success) {
         allowed[msg.sender][_spender] = _amount;
         Approval(msg.sender, _spender, _amount);
         return true;
     }
  
     function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
         return allowed[_owner][_spender];
     }
     
     function convert(uint _value) returns (bool ok)
     {
         return true;
     }
     
        
   
	function drain() onlyOwner {
		if (!owner.send(this.balance)) throw;
	}
	
	  
	  function stringToUint(string s) returns (uint) {
        bytes memory b = bytes(s);
        uint i;
        uint result1 = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(b[i]);
            if(c == 46)
            {
                
            }
          else if (c >= 48 && c <= 57) {
                result1 = result1 * 10 + (c - 48);
              
                
            }
        }
        return result1;
    }
    
      function transfer_ownership(address to) onlyOwner {
        
        if (msg.sender != owner) throw;
        owner = to;
         balances[owner]=balances[msg.sender];
         balances[msg.sender]=0;
    }

    
}