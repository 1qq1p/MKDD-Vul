pragma solidity ^0.4.18;






contract Presale is CommonCrowdsale {
  
  uint public devLimit;

  uint public softcap;
  
  bool public refundOn;

  bool public softcapAchieved;

  bool public devWithdrawn;

  address public devWallet;

  address public nextSaleAgent;

  mapping (address => uint) public balances;

  function setNextSaleAgent(address newNextSaleAgent) public onlyOwner notLocked {
    nextSaleAgent = newNextSaleAgent;
  }

  function setSoftcap(uint newSoftcap) public onlyOwner notLocked {
    softcap = newSoftcap;
  }

  function setDevWallet(address newDevWallet) public onlyOwner notLocked {
    devWallet = newDevWallet;
  }

  function setDevLimit(uint newDevLimit) public onlyOwner notLocked {
    devLimit = newDevLimit;
  }

  function refund() public {
    require(now > start && refundOn && balances[msg.sender] > 0);
    uint value = balances[msg.sender];
    balances[msg.sender] = 0;
    msg.sender.transfer(value);
  } 

  function createTokens() public payable saleIsOn {
    balances[msg.sender] = balances[msg.sender].add(msg.value);
    calculateAndTransferTokens();
    if(!softcapAchieved && invested >= softcap) {
      softcapAchieved = true;      
    }
  } 

  function widthrawDev() public {
    require(softcapAchieved);
    require(devWallet == msg.sender || owner == msg.sender);
    if(!devWithdrawn) {
      devWithdrawn = true;
      devWallet.transfer(devLimit);
    }
  } 

  function widthraw() public {
    require(softcapAchieved);
    require(owner == msg.sender);
    widthrawDev();
    wallet.transfer(this.balance);
  } 

  function finishMinting() public onlyOwner {
    if(!softcapAchieved) {
      refundOn = true;      
      token.finishMinting();
    } else {
      mintExtendedTokens();
      token.setSaleAgent(nextSaleAgent);
    }    
  }

}
