pragma solidity ^0.4.19;








contract FreezableToken is Administrable {

    mapping (address => bool) public frozenList;

    event FrozenFunds(address indexed wallet, bool frozen);

    



    function freezeAccount(address _wallet) onlyAdministratorOrOwner public {
        require(_wallet != address(0));
        frozenList[_wallet] = true;
        FrozenFunds(_wallet, true);
    }

    



    function unfreezeAccount(address _wallet) onlyAdministratorOrOwner public {
        require(_wallet != address(0));
        frozenList[_wallet] = false;
        FrozenFunds(_wallet, false);
    }

    


 
    function isFrozen(address _wallet) constant public returns (bool) {
        return frozenList[_wallet];
    }

}







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







