pragma solidity ^0.4.25;





interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}





library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); 
    uint256 c = a / b;
    

    return c;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  



  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}












contract Ownable {
  address private _owner;

  



  constructor() public {
    _owner = msg.sender;
  }

  


  function owner() public view returns(address) {
    return _owner;
  }

  


  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  


  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  



  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    _owner = newOwner;
  }
}

interface TransferAndCallFallBack {
    function tokenFallback(address _from, 
                           uint    _value, 
                           bytes   _data) external returns (bool);
}

interface ApproveAndCallFallBack {
    function receiveApproval(address _owner, 
                             uint256 _value, 
                             bytes   _data) external returns (bool);
}
