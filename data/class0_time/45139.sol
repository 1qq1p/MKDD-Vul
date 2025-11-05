pragma solidity ^0.4.23;



contract OperatorManaged is Ownable {

    address public operatorAddress;
    address public adminAddress;

    event AdminAddressChanged(address indexed _newAddress);
    event OperatorAddressChanged(address indexed _newAddress);


    constructor() public
        Ownable()
    {
        adminAddress = msg.sender;
    }

    modifier onlyAdmin() {
        require(isAdmin(msg.sender));
        _;
    }


    modifier onlyAdminOrOperator() {
        require(isAdmin(msg.sender) || isOperator(msg.sender));
        _;
    }


    modifier onlyOwnerOrAdmin() {
        require(isOwner(msg.sender) || isAdmin(msg.sender));
        _;
    }


    modifier onlyOperator() {
        require(isOperator(msg.sender));
        _;
    }


    function isAdmin(address _address) internal view returns (bool) {
        return (adminAddress != address(0) && _address == adminAddress);
    }


    function isOperator(address _address) internal view returns (bool) {
        return (operatorAddress != address(0) && _address == operatorAddress);
    }

    function isOwner(address _address) internal view returns (bool) {
        return (owner != address(0) && _address == owner);
    }


    function isOwnerOrOperator(address _address) internal view returns (bool) {
        return (isOwner(_address) || isOperator(_address));
    }


    
    function setAdminAddress(address _adminAddress) external onlyOwnerOrAdmin returns (bool) {
        require(_adminAddress != owner);
        require(_adminAddress != address(this));
        require(!isOperator(_adminAddress));

        adminAddress = _adminAddress;

        emit AdminAddressChanged(_adminAddress);

        return true;
    }


    
    function setOperatorAddress(address _operatorAddress) external onlyOwnerOrAdmin returns (bool) {
        require(_operatorAddress != owner);
        require(_operatorAddress != address(this));
        require(!isAdmin(_operatorAddress));

        operatorAddress = _operatorAddress;

        emit OperatorAddressChanged(_operatorAddress);

        return true;
    }
}







library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    
    
    
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}







