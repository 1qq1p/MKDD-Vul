pragma solidity ^0.4.18;






library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}







contract Token is StandardToken , MintableToken, CappedToken {

    string public constant name = 'Bitcoin Empowerment Coin';
    string public constant symbol = 'BEC';
    uint8 public constant decimals = 18;

    function Token()
        public
        payable
         CappedToken(30000000000*10**uint(decimals))
    {
        
                uint premintAmount = 5000000000*10**uint(decimals);
                totalSupply_ = totalSupply_.add(premintAmount);
                balances[msg.sender] = balances[msg.sender].add(premintAmount);
                Transfer(address(0), msg.sender, premintAmount);

            
        
    }

}