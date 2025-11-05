pragma solidity ^0.5.0;





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






contract Ownable {
  address payable public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  



  constructor() public {
    owner = msg.sender;
  }

  


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  



  function transferOwnership(address payable _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  



  function _transferOwnership(address payable _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}





 