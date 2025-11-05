pragma solidity ^0.4.21;






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







contract Kubic is BurnableToken, Ownable {


    
    string public constant name = "Kubic";
    string public constant symbol = "KIC";
    uint public constant decimals = 8; 
    uint256 public constant initialSupply = 300000000 * (10 ** uint256(decimals));

    
    function Kubic() {
        totalSupply = initialSupply;
        balances[msg.sender] = initialSupply; 
    }
}