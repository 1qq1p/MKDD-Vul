pragma solidity ^0.4.20;

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










contract admined { 
    address public admin; 
    address public allowedAddress; 

    



    function admined() internal {
        admin = msg.sender; 
        Admined(admin);
    }

   



    function setAllowedAddress(address _to) onlyAdmin public {
        allowedAddress = _to;
        AllowedSet(_to);
    }

    modifier onlyAdmin() { 
        require(msg.sender == admin);
        _;
    }

    modifier crowdsaleonly() { 
        require(allowedAddress == msg.sender);
        _;
    }

   



    function transferAdminship(address _newAdmin) onlyAdmin public { 
        require(_newAdmin != 0);
        admin = _newAdmin;
        TransferAdminship(admin);
    }


    
    event AllowedSet(address _to);
    event TransferAdminship(address newAdminister);
    event Admined(address administer);

}




