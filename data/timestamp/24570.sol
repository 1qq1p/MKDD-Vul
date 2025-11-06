pragma solidity ^0.4.12;





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







contract PCNCoin is BurnableToken, Ownable {

    string public constant name = "PCN Coin";
    string public constant symbol = "PCN";
    uint public constant decimals = 18;
    
    uint256 public constant initialSupply = 900000000 * (10 ** uint256(decimals));

    
    function PCNCoin () {
        totalSupply = initialSupply;
        balances[msg.sender] = initialSupply; 
    }

}