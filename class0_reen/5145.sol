pragma solidity ^0.4.21;



interface Bankroll {

    

    
    function credit(address _customerAddress, uint256 amount) external returns (uint256);

    
    function debit(address _customerAddress, uint256 amount) external returns (uint256);

    
    function withdraw(address _customerAddress) external returns (uint256);

    
    function balanceOf(address _customerAddress) external view returns (uint256);

    
    function statsOf(address _customerAddress) external view returns (uint256[8]);


    

    
    function deposit() external payable;

    
    function depositBy(address _customerAddress) external payable;

    
    function houseProfit(uint256 amount)  external;


    
    function netEthereumBalance() external view returns (uint256);


    
    function totalEthereumBalance() external view returns (uint256);

}




contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  



  constructor() public {
    owner = msg.sender;
  }

  


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  



  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}







