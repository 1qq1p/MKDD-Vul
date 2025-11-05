pragma solidity ^0.4.15;

contract Forwarder {
    
  
  address private parentAddress = 0x7aeCf441966CA8486F4cBAa62fa9eF2D557f9ba7;
  
  
  address[] private owners = [0x6CAa636cFFbCbb2043A3322c04dE3f26b1fa6555, 0xbc2d90C2D3A87ba3fC8B23aA951A9936A6D68121, 0x680d821fFE703762E7755c52C2a5E8556519EEDc];
  
  event ForwarderDeposited(address from, uint value, bytes data);

  


  constructor() public {

  }

  


  modifier onlyOwner {
    require(msg.sender == owners[0] || msg.sender == owners[1] || msg.sender == owners[2]);
    _;
  }

  


  function() public payable {
    
    parentAddress.transfer(msg.value);
    
    emit ForwarderDeposited(msg.sender, msg.value, msg.data);
  }


  



  function flushTokens(address tokenContractAddress) public onlyOwner {
    ERC20Interface instance = ERC20Interface(tokenContractAddress);
    address forwarderAddress = address(this);
    uint forwarderBalance = instance.balanceOf(forwarderAddress);
    if (forwarderBalance == 0) {
      return;
    }
    if (!instance.transfer(parentAddress, forwarderBalance)) {
      revert();
    }
  }

  



  function flush() public onlyOwner {
    
    uint my_balance = address(this).balance;
    if (my_balance == 0){
        return;
    } else {
        parentAddress.transfer(address(this).balance);
    }
  }
}
