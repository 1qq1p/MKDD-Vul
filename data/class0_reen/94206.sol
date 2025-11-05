pragma solidity ^0.4.16;

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

contract FarmCoin is StandardToken {

   
    

    





    string public name = 'WorldFarmCoin';                   
    uint8 public decimals = 0;                
    string public symbol = 'WFARM';                 
    string public version = 'H1.0';       







    function FarmCoin(
        ) {
        balances[msg.sender] = 5000000;               
        totalSupply = 5000000;                        
        name = "WorldFarmCoin";                                   
        decimals = 0;                            
        symbol = "WFARM";                               
    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        
        
        
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert; }
        return true;
    }
}

