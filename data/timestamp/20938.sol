pragma solidity ^0.4.18;






library SafeMath {

  


  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    return a - b;
  }

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;
    require(a == b * c + a % b); 
    return c;
  }

}







contract LiXiangToken is StandardToken {

    string public constant name = "LiXiang Token";
    string public constant symbol = "LXT";
    uint8 public constant decimals = 12;

    uint256 public constant INITIAL_SUPPLY = 21 * (10 ** 8) * (10 ** uint256(decimals));

    


    function LiXiangToken() public {
        _totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }

}