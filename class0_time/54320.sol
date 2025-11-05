pragma solidity ^0.4.21;









library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;

        return c;
    }

    function minus(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);

        return a - b;
    }

    function plus(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);

        return c;
    }
}






contract TIMETokenSafe is TokenSafe {
  constructor(address _token)
    TokenSafe(_token)
    public
  {
    
    
    init(
      1, 
      1544054400 
    );
    add(
      1, 
      0x40396b24301e6dFEc5DAC9c2873c1Ef0A5754D6A,  
      840000000000000000000000  
    );
  }
}






