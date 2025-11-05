pragma solidity 0.4.25;

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

contract Salary {
  using SafeMath for uint256;
  address public admin;
  mapping(address => bool) public helperAddressTable;
  address[] public addressList;
  uint256 public deliveredId;
  
  

  mapping(address => mapping(uint256 => uint256)) public staffSalaryData;
  
  mapping(address => uint256) public staffSalaryStatus;

  ERC20 token;

  event TerminatePackage(address indexed staff);
  event ChangeTokenContractAddress(address indexed newAddress);
  
  modifier onlyAdmin() {
    require(msg.sender == admin);
    _;
  }

  modifier onlyHelper() {
    require(msg.sender == admin || helperAddressTable[msg.sender] == true);
    _;
  }

  function getFullAddressList() view public returns(address[]) {
    return addressList;
  }

  


  function distribute() public onlyAdmin {
    uint256 i;
    address receiverAddress;
    uint256 transferAmount;
    for(i = 0; i < addressList.length; i++) {
      receiverAddress = addressList[i];
      if (staffSalaryStatus[receiverAddress] == 1) {
        transferAmount = staffSalaryData[receiverAddress][deliveredId];
        if (transferAmount > 0) {
          require(token.transfer(receiverAddress, transferAmount));
        }
      }
    }
    deliveredId = deliveredId + 1;
  }

  






  function newPackage(address _staffAddress, uint256[] _monthlySalary) external onlyHelper{
    uint256 i;
    uint256 packageTotalAmount = 0;
    require(staffSalaryStatus[_staffAddress] == 0);
    for (i = 0; i < _monthlySalary.length; i++) {
      staffSalaryData[_staffAddress][deliveredId + i] = _monthlySalary[i];
      packageTotalAmount = packageTotalAmount + _monthlySalary[i];
    }
    addressList.push(_staffAddress);
    staffSalaryStatus[_staffAddress] = 1;
    require(token.transferFrom(msg.sender, address(this), packageTotalAmount));
  }

  






  function terminatePackage(address _staffAddress) external onlyAdmin {
    emit TerminatePackage(_staffAddress);
    staffSalaryStatus[_staffAddress] = 2;
  }

  function withdrawToken(uint256 amount) public onlyAdmin {
    require(token.transfer(admin, amount));
  }

  




  function setHelper(address _helperAddress) external onlyAdmin {
    helperAddressTable[_helperAddress] = true;
  }

  





  function removeHelper(address _helperAddress) external onlyAdmin {
    require(helperAddressTable[_helperAddress] = true);
    helperAddressTable[_helperAddress] = false;
  }

  


 
  function changeTokenContractAddress(address _newAddress) external onlyAdmin {
    require(_newAddress != address(0));
    token = ERC20(_newAddress);
    emit ChangeTokenContractAddress(_newAddress);
  }

  constructor (address _tokenAddress) public {
    admin = msg.sender;
    token = ERC20(_tokenAddress);
  }
}