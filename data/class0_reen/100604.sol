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

contract MIP is StandardToken{
    string public constant name = "Movie Intellectual Property";
    string public constant symbol = "MIP";
    uint public constant decimals = 18;
    string public constant version = "1.0";
    address public owner;
    
    modifier onlyOwner{
      if(msg.sender != owner) throw;
      _;
    }
    
    function MIP(){
        owner = msg.sender;
        totalSupply = 1*(10**8)*(10**decimals);
        balances[owner] =  totalSupply;
    }

    function changeOwner(address newOwner) onlyOwner{
      owner = newOwner;
    }

    
    function () payable{
        throw;
    }
    
    function kill() onlyOwner{
        suicide(owner);
    }
}