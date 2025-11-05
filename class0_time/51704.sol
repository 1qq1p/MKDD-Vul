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















contract LiteDashCoin is BurnableToken, Ownable {



    string public constant name = "LiteDash";

    string public constant symbol = "LDASH";

    uint public constant decimals = 18;

    uint256 public constant initialSupply = 18900000 * (10 ** uint256(decimals));



    

    function LiteDashCoin() {

        totalSupply = initialSupply;

        balances[msg.sender] = initialSupply; 

    }

}