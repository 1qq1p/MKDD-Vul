























pragma solidity ^0.4.24;








contract AuditableToken is IAuditableToken, StandardToken {

   
   
   
   
  struct Audit {
    uint256 createdAt;
    uint256 lastReceivedAt;
    uint256 lastSentAt;
    uint256 receivedCount; 
    uint256 sentCount; 
    uint256 totalReceivedAmount; 
    uint256 totalSentAmount; 
  }
  mapping(address => Audit) internal audits;

  


  function auditCreatedAt(address _address) public view returns (uint256) {
    return audits[_address].createdAt;
  }

  


  function lastTransactionAt(address _address) public view returns (uint256) {
    return ( audits[_address].lastReceivedAt > audits[_address].lastSentAt ) ?
      audits[_address].lastReceivedAt : audits[_address].lastSentAt;
  }

  


  function lastReceivedAt(address _address) public view returns (uint256) {
    return audits[_address].lastReceivedAt;
  }

  


  function lastSentAt(address _address) public view returns (uint256) {
    return audits[_address].lastSentAt;
  }

  


  function transactionCount(address _address) public view returns (uint256) {
    return audits[_address].receivedCount + audits[_address].sentCount;
  }

  


  function receivedCount(address _address) public view returns (uint256) {
    return audits[_address].receivedCount;
  }

  


  function sentCount(address _address) public view returns (uint256) {
    return audits[_address].sentCount;
  }

  


  function totalReceivedAmount(address _address)
    public view returns (uint256)
  {
    return audits[_address].totalReceivedAmount;
  }

  


  function totalSentAmount(address _address) public view returns (uint256) {
    return audits[_address].totalSentAmount;
  }

  


  function transfer(address _to, uint256 _value) public returns (bool) {
    if (!super.transfer(_to, _value)) {
      return false;
    }
    updateAudit(msg.sender, _to, _value);
    return true;
  }

  


  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool)
  {
    if (!super.transferFrom(_from, _to, _value)) {
      return false;
    }

    updateAudit(_from, _to, _value);
    return true;
  }

 


  function currentTime() internal view returns (uint256) {
    
    return now;
  }

  


  function updateAudit(address _sender, address _receiver, uint256 _value)
    private returns (uint256)
  {
    Audit storage senderAudit = audits[_sender];
    senderAudit.lastSentAt = currentTime();
    senderAudit.sentCount++;
    senderAudit.totalSentAmount += _value;
    if (senderAudit.createdAt == 0) {
      senderAudit.createdAt = currentTime();
    }

    Audit storage receiverAudit = audits[_receiver];
    receiverAudit.lastReceivedAt = currentTime();
    receiverAudit.receivedCount++;
    receiverAudit.totalReceivedAmount += _value;
    if (receiverAudit.createdAt == 0) {
      receiverAudit.createdAt = currentTime();
    }
  }
}

















