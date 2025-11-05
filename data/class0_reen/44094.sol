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






contract CenturyXTokenSafe is TokenSafe {
  constructor(address _token)
    TokenSafe(_token)
    public
  {
    
    
    init(
      1, 
      1544724000 
    );
    add(
      1, 
      0x1ffdaB90db08d0e8315e047A89A196ae657ed280,  
      4800000000000000000000000  
    );
    add(
      1, 
      0x1ffdaB90db08d0e8315e047A89A196ae657ed280,  
      210000000000000000000000  
    );
    
    
    init(
      2, 
      1551434400 
    );
    add(
      2, 
      0x1ffdaB90db08d0e8315e047A89A196ae657ed280,  
      3570000000000000000000000  
    );
    
    
    init(
      3, 
      1591005600 
    );
    add(
      3, 
      0x1ffdaB90db08d0e8315e047A89A196ae657ed280,  
      6300000000000000000000000  
    );
  }
}






