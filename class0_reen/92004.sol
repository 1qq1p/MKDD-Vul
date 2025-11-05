pragma solidity ^0.4.23;







library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    
    
    
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}








contract GameTestToken is PausableToken
{
  using SafeMath for uint256;
  
  
  string public name="Game Test Token";
  string public symbol="GTT";
  string public standard="ERC20";
  
  uint8 public constant decimals = 2; 
  
  uint256 public constant INITIAL_SUPPLY = 25 *(10**8)*(10 ** uint256(decimals));
  
  event ReleaseTarget(address target);
    
  mapping(address => TimeLock[]) public allocations;
  
  struct TimeLock
  {
      uint time;
      uint256 balance;
  }

  
  constructor() public 
  {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
  }

  




  function transfer(address _to, uint256 _value) public returns (bool) 
  {
      require(canSubAllocation(msg.sender, _value));
    
      subAllocation(msg.sender);
    
      return super.transfer(_to, _value); 
  }
  
  function canSubAllocation(address sender, uint256 sub_value) private constant returns (bool)
  {
      if (sub_value==0)
      {
          return false;
      }
      
      if (balances[sender] < sub_value)
      {
          return false;
      }
      
      uint256 alllock_sum = 0;
      for (uint j=0; j<allocations[sender].length; j++)
      {
          if (allocations[sender][j].time >= block.timestamp)
          {
              alllock_sum = alllock_sum.add(allocations[sender][j].balance);
          }
      }
      
      uint256 can_unlock = balances[sender].sub(alllock_sum);
      
      return can_unlock >= sub_value;
  }
  
  function subAllocation(address sender) private
  {
      for (uint j=0; j<allocations[sender].length; j++)
      {
          if (allocations[sender][j].time < block.timestamp)
          {
              allocations[sender][j].balance = 0;
          }
      }
  }
  
  function setAllocation(address _address, uint256 total_value, uint[] times, uint256[] balanceRequires) public onlyOwner returns (bool)
  {
      require(times.length == balanceRequires.length);
      uint256 sum = 0;
      for (uint x=0; x<balanceRequires.length; x++)
      {
          require(balanceRequires[x]>0);
          sum = sum.add(balanceRequires[x]);
      }
      
      require(total_value >= sum);
      
      require(balances[msg.sender]>=sum);

      for (uint i=0; i<times.length; i++)
      {
          bool find = false;
          
          for (uint j=0; j<allocations[_address].length; j++)
          {
              if (allocations[_address][j].time == times[i])
              {
                  allocations[_address][j].balance = allocations[_address][j].balance.add(balanceRequires[i]);
                  find = true;
                  break;
              }
          }
          
          if (!find)
          {
              allocations[_address].push(TimeLock(times[i], balanceRequires[i]));
          }
      }
      
      return super.transfer(_address, total_value); 
  }
  
  function releaseAllocation(address target)  public onlyOwner 
  {
      require(balances[target] > 0);
      
      for (uint j=0; j<allocations[target].length; j++)
      {
          allocations[target][j].balance = 0;
      }
      
      emit ReleaseTarget(target);
  }
}