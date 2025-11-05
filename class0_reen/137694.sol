pragma solidity ^0.4.24;










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
    bool public lockSupply; 

    



    constructor() internal {
        admin = msg.sender; 
        emit Admined(admin);
    }

    modifier onlyAdmin() { 
        require(msg.sender == admin);
        _;
    }

    modifier supplyLock() { 
        require(lockSupply == false);
        _;
    }

   



    function transferAdminship(address _newAdmin) onlyAdmin public { 
        require(_newAdmin != 0);
        admin = _newAdmin;
        emit TransferAdminship(admin);
    }

   



    function setSupplyLock(bool _set) onlyAdmin public { 
        lockSupply = _set;
        emit SetSupplyLock(_set);
    }

    
    event SetSupplyLock(bool _set);
    event TransferAdminship(address newAdminister);
    event Admined(address administer);

}





