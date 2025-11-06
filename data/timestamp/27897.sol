pragma solidity ^0.4.24;






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







contract JUNOToken is DividendToken , CappedDividendToken {
    string public constant name = 'JUNO';
    string public constant symbol = 'JUNO';
    uint8 public constant decimals = 18;

    function JUNOToken()
        public
        payable
         CappedDividendToken(10000000*10**uint(decimals))
    {
        
                uint premintAmount = 6000*10**uint(decimals);
                totalSupply_ = totalSupply_.add(premintAmount);
                balances[msg.sender] = balances[msg.sender].add(premintAmount);
                Transfer(address(0), msg.sender, premintAmount);

                m_emissions.push(EmissionInfo({
                    totalSupply: totalSupply_,
                    totalBalanceWas: 0
                }));

            
        
            
    }

}