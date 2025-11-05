pragma solidity ^0.4.11;

library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    
    uint c = a / b;
    
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}

contract EGC is StandardToken{
    string public constant name = "ExchangeGoodsChain";
    string public constant symbol = "EGC";
    uint public constant decimals = 18;
    string public constant version = "1.0";
    
    
    address public host;
    
    address public owner;

    modifier onlyOwner{
      if(msg.sender != owner) throw;
      _;
    } 

    
    event InitHostBalance(address _host,uint number);

    function EGC(){
        owner = msg.sender;
        
        totalSupply = 13*(10**8)*(10**decimals);
    }

    function initToken(address _host) onlyOwner{
      
      if(_host==0x0) throw;
      host = _host;
      balances[host] = balances[host].add(totalSupply);
      InitHostBalance(host,totalSupply);
    }

    function changeOwner(address newOwner) onlyOwner{
      owner = newOwner;
    }

    
    function () payable{
        throw;
    }
    
    function kill() onlyOwner{
        selfdestruct(owner);
    }
}