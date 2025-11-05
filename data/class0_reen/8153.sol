pragma solidity 0.4.25;






































library LinkedListLib {

    uint256 constant NULL = 0;
    uint256 constant HEAD = 0;
    bool constant PREV = false;
    bool constant NEXT = true;

    struct LinkedList{
        mapping (uint256 => mapping (bool => uint256)) list;
    }

    
    
    function listExists(LinkedList storage self)
        public
        view returns (bool)
    {
        
        if (self.list[HEAD][PREV] != HEAD || self.list[HEAD][NEXT] != HEAD) {
            return true;
        } else {
            return false;
        }
    }

    
    
    
    function nodeExists(LinkedList storage self, uint256 _node)
        public
        view returns (bool)
    {
        if (self.list[_node][PREV] == HEAD && self.list[_node][NEXT] == HEAD) {
            if (self.list[HEAD][NEXT] == _node) {
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
    }

    
    
    function sizeOf(LinkedList storage self) public view returns (uint256 numElements) {
        bool exists;
        uint256 i;
        (exists,i) = getAdjacent(self, HEAD, NEXT);
        while (i != HEAD) {
            (exists,i) = getAdjacent(self, i, NEXT);
            numElements++;
        }
        return;
    }

    
    
    
    function getNode(LinkedList storage self, uint256 _node)
        public view returns (bool,uint256,uint256)
    {
        if (!nodeExists(self,_node)) {
            return (false,0,0);
        } else {
            return (true,self.list[_node][PREV], self.list[_node][NEXT]);
        }
    }

    
    
    
    
    function getAdjacent(LinkedList storage self, uint256 _node, bool _direction)
        public view returns (bool,uint256)
    {
        if (!nodeExists(self,_node)) {
            return (false,0);
        } else {
            return (true,self.list[_node][_direction]);
        }
    }

    
    
    
    
    
    
    function getSortedSpot(LinkedList storage self, uint256 _node, uint256 _value, bool _direction)
        public view returns (uint256)
    {
        if (sizeOf(self) == 0) { return 0; }
        require((_node == 0) || nodeExists(self,_node));
        bool exists;
        uint256 next;
        (exists,next) = getAdjacent(self, _node, _direction);
        while  ((next != 0) && (_value != next) && ((_value < next) != _direction)) next = self.list[next][_direction];
        return next;
    }

    
    
    
    
    function createLink(LinkedList storage self, uint256 _node, uint256 _link, bool _direction) private  {
        self.list[_link][!_direction] = _node;
        self.list[_node][_direction] = _link;
    }

    
    
    
    
    
    function insert(LinkedList storage self, uint256 _node, uint256 _new, bool _direction) internal returns (bool) {
        if(!nodeExists(self,_new) && nodeExists(self,_node)) {
            uint256 c = self.list[_node][_direction];
            createLink(self, _node, _new, _direction);
            createLink(self, _new, c, _direction);
            return true;
        } else {
            return false;
        }
    }

    
    
    
    function remove(LinkedList storage self, uint256 _node) internal returns (uint256) {
        if ((_node == NULL) || (!nodeExists(self,_node))) { return 0; }
        createLink(self, self.list[_node][PREV], self.list[_node][NEXT], NEXT);
        delete self.list[_node][PREV];
        delete self.list[_node][NEXT];
        return _node;
    }

    
    
    
    
    function push(LinkedList storage self, uint256 _node, bool _direction) internal  {
        insert(self, HEAD, _node, _direction);
    }

    
    
    
    function pop(LinkedList storage self, bool _direction) internal returns (uint256) {
        bool exists;
        uint256 adj;

        (exists,adj) = getAdjacent(self, HEAD, _direction);

        return remove(self, adj);
    }
}








contract QuantstampAudit is Pausable {
  using SafeMath for uint256;
  using LinkedListLib for LinkedListLib.LinkedList;

  
  uint256 constant internal NULL = 0;
  uint256 constant internal HEAD = 0;
  bool constant internal PREV = false;
  bool constant internal NEXT = true;

  uint256 private minAuditPriceLowerCap = 0;

  
  mapping(address => uint256) public assignedRequestCount;

  
  LinkedListLib.LinkedList internal priceList;
  
  mapping(uint256 => LinkedListLib.LinkedList) internal auditsByPrice;

  
  LinkedListLib.LinkedList internal assignedAudits;

  
  mapping(address => uint256) public mostRecentAssignedRequestIdsPerAuditor;

  
  QuantstampAuditData public auditData;

  
  QuantstampAuditReportData public reportData;

  
  QuantstampAuditPolice public police;

  
  QuantstampAuditTokenEscrow public tokenEscrow;

  event LogAuditFinished(
    uint256 requestId,
    address auditor,
    QuantstampAuditData.AuditState auditResult,
    bytes report
  );

  event LogPoliceAuditFinished(
    uint256 requestId,
    address policeNode,
    bytes report,
    bool isVerified
  );

  event LogAuditRequested(uint256 requestId,
    address requestor,
    string uri,
    uint256 price
  );

  event LogAuditAssigned(uint256 requestId,
    address auditor,
    address requestor,
    string uri,
    uint256 price,
    uint256 requestBlockNumber);

  
  event LogReportSubmissionError_InvalidAuditor(uint256 requestId, address auditor);
  event LogReportSubmissionError_InvalidState(uint256 requestId, address auditor, QuantstampAuditData.AuditState state);
  event LogReportSubmissionError_InvalidResult(uint256 requestId, address auditor, QuantstampAuditData.AuditState state);
  event LogReportSubmissionError_ExpiredAudit(uint256 requestId, address auditor, uint256 allowanceBlockNumber);
  event LogAuditAssignmentError_ExceededMaxAssignedRequests(address auditor);
  event LogAuditAssignmentError_Understaked(address auditor, uint256 stake);
  event LogAuditAssignmentUpdate_Expired(uint256 requestId, uint256 allowanceBlockNumber);
  event LogClaimRewardsReachedGasLimit(address auditor);

  

  event LogAuditQueueIsEmpty();

  event LogPayAuditor(uint256 requestId, address auditor, uint256 amount);
  event LogAuditNodePriceChanged(address auditor, uint256 amount);

  event LogRefund(uint256 requestId, address requestor, uint256 amount);
  event LogRefundInvalidRequestor(uint256 requestId, address requestor);
  event LogRefundInvalidState(uint256 requestId, QuantstampAuditData.AuditState state);
  event LogRefundInvalidFundsLocked(uint256 requestId, uint256 currentBlock, uint256 fundLockEndBlock);

  
  
  event LogAuditNodePriceHigherThanRequests(address auditor, uint256 amount);

  enum AuditAvailabilityState {
    Error,
    Ready,      
    Empty,      
    Exceeded,   
    Underpriced, 
    Understaked 
  }

  






  constructor (address auditDataAddress, address reportDataAddress, address escrowAddress, address policeAddress) public {
    require(auditDataAddress != address(0));
    require(reportDataAddress != address(0));
    require(escrowAddress != address(0));
    require(policeAddress != address(0));
    auditData = QuantstampAuditData(auditDataAddress);
    reportData = QuantstampAuditReportData(reportDataAddress);
    tokenEscrow = QuantstampAuditTokenEscrow(escrowAddress);
    police = QuantstampAuditPolice(policeAddress);
  }

  



  function setMinAuditPriceLowerCap(uint256 amount) external onlyOwner {
    minAuditPriceLowerCap = amount;
  }

  



  function stake(uint256 amount) external returns(bool) {
    
    require(auditData.token().transferFrom(msg.sender, address(this), amount));
    
    auditData.token().approve(address(tokenEscrow), amount);
    
    tokenEscrow.deposit(msg.sender, amount);
    return true;
  }

  


  function unstake() external returns(bool) {
    
    tokenEscrow.withdraw(msg.sender);
    return true;
  }

  



  function refund(uint256 requestId) external returns(bool) {
    QuantstampAuditData.AuditState state = auditData.getAuditState(requestId);
    
    if (state != QuantstampAuditData.AuditState.Queued &&
          state != QuantstampAuditData.AuditState.Assigned &&
            state != QuantstampAuditData.AuditState.Expired) {
      emit LogRefundInvalidState(requestId, state);
      return false;
    }
    address requestor = auditData.getAuditRequestor(requestId);
    if (requestor != msg.sender) {
      emit LogRefundInvalidRequestor(requestId, msg.sender);
      return;
    }
    uint256 refundBlockNumber = auditData.getAuditAssignBlockNumber(requestId).add(auditData.auditTimeoutInBlocks());
    
    if (state == QuantstampAuditData.AuditState.Assigned) {
      if (block.number <= refundBlockNumber) {
        emit LogRefundInvalidFundsLocked(requestId, block.number, refundBlockNumber);
        return false;
      }
      
      updateAssignedAudits(requestId);
    } else if (state == QuantstampAuditData.AuditState.Queued) {
      
      
      removeQueueElement(requestId);
    }

    
    auditData.setAuditState(requestId, QuantstampAuditData.AuditState.Refunded);

    
    uint256 price = auditData.getAuditPrice(requestId);
    emit LogRefund(requestId, requestor, price);
    safeTransferFromDataContract(requestor, price);
    return true;
  }

  




  function requestAudit(string contractUri, uint256 price) public returns(uint256) {
    
    return requestAuditWithPriceHint(contractUri, price, HEAD);
  }

  





  function requestAuditWithPriceHint(string contractUri, uint256 price, uint256 existingPrice) public whenNotPaused returns(uint256) {
    require(price > 0);
    require(price >= minAuditPriceLowerCap);

    
    require(auditData.token().transferFrom(msg.sender, address(auditData), price));
    
    uint256 requestId = auditData.addAuditRequest(msg.sender, contractUri, price);

    queueAuditRequest(requestId, existingPrice);

    emit LogAuditRequested(requestId, msg.sender, contractUri, price); 

    return requestId;
  }

  





  function submitReport(uint256 requestId, QuantstampAuditData.AuditState auditResult, bytes report) public { 
    if (QuantstampAuditData.AuditState.Completed != auditResult && QuantstampAuditData.AuditState.Error != auditResult) {
      emit LogReportSubmissionError_InvalidResult(requestId, msg.sender, auditResult);
      return;
    }

    QuantstampAuditData.AuditState auditState = auditData.getAuditState(requestId);
    if (auditState != QuantstampAuditData.AuditState.Assigned) {
      emit LogReportSubmissionError_InvalidState(requestId, msg.sender, auditState);
      return;
    }

    
    if (msg.sender != auditData.getAuditAuditor(requestId)) {
      emit LogReportSubmissionError_InvalidAuditor(requestId, msg.sender);
      return;
    }

    
    updateAssignedAudits(requestId);

    
    uint256 allowanceBlockNumber = auditData.getAuditAssignBlockNumber(requestId) + auditData.auditTimeoutInBlocks();
    if (allowanceBlockNumber < block.number) {
      
      auditData.setAuditState(requestId, QuantstampAuditData.AuditState.Expired);
      emit LogReportSubmissionError_ExpiredAudit(requestId, msg.sender, allowanceBlockNumber);
      return;
    }

    
    auditData.setAuditState(requestId, auditResult);
    auditData.setAuditReportBlockNumber(requestId, block.number); 

    
    require(isAuditFinished(requestId));

    
    reportData.setReport(requestId, report);

    emit LogAuditFinished(requestId, msg.sender, auditResult, report);

    
    police.assignPoliceToReport(requestId);
    
    police.addPendingPayment(msg.sender, requestId);
    
    if (police.reportProcessingFeePercentage() > 0 && police.numPoliceNodes() > 0) {
      uint256 policeFee = police.collectFee(requestId);
      safeTransferFromDataContract(address(police), policeFee);
      police.splitPayment(policeFee);
    }
  }

  



  function getReport(uint256 requestId) public view returns (bytes) {
    return reportData.getReport(requestId);
  }

  




  function isPoliceNode(address node) public view returns(bool) {
    return police.isPoliceNode(node);
  }

  







  function submitPoliceReport(
    uint256 requestId,
    bytes report,
    bool isVerified) public returns (bool) {
    require(police.isPoliceNode(msg.sender));
    
    address auditNode = auditData.getAuditAuditor(requestId);
    bool hasBeenSubmitted;
    bool slashOccurred;
    uint256 slashAmount;
    
    (hasBeenSubmitted, slashOccurred, slashAmount) = police.submitPoliceReport(msg.sender, auditNode, requestId, report, isVerified);
    if (hasBeenSubmitted) {
      emit LogPoliceAuditFinished(requestId, msg.sender, report, isVerified);
    }
    if (slashOccurred) {
      
      uint256 auditPoliceFee = police.collectedFees(requestId);
      uint256 adjustedPrice = auditData.getAuditPrice(requestId).sub(auditPoliceFee);
      safeTransferFromDataContract(address(police), adjustedPrice);

      
      police.splitPayment(adjustedPrice.add(slashAmount));
    }
    return hasBeenSubmitted;
  }

  


  function hasAvailableRewards () public view returns (bool) {
    bool exists;
    uint256 next;
    (exists, next) = police.getNextAvailableReward(msg.sender, HEAD);
    return exists;
  }

  


  function getMinAuditPriceLowerCap() public view returns(uint256) {
    return minAuditPriceLowerCap;
  }

  





  function getNextAvailableReward (uint256 requestId) public view returns(bool, uint256) {
    return police.getNextAvailableReward(msg.sender, requestId);
  }

  







  function claimReward (uint256 requestId) public returns (bool) {
    require(police.canClaimAuditReward(msg.sender, requestId));
    police.setRewardClaimed(msg.sender, requestId);
    transferReward(requestId);
    return true;
  }

  



  function claimRewards () public returns (bool) {
    
    require(hasAvailableRewards());
    bool exists;
    uint256 requestId = HEAD;
    uint256 remainingGasBeforeCall;
    uint256 remainingGasAfterCall;
    bool loopExitedDueToGasLimit;
    
    
    while (true) {
      remainingGasBeforeCall = gasleft();
      (exists, requestId) = police.claimNextReward(msg.sender, HEAD);
      if (!exists) {
        break;
      }
      transferReward(requestId);
      remainingGasAfterCall = gasleft();
      
      if (remainingGasAfterCall < remainingGasBeforeCall.sub(remainingGasAfterCall).mul(2)) {
        loopExitedDueToGasLimit = true;
        emit LogClaimRewardsReachedGasLimit(msg.sender);
        break;
      }
    }
    return loopExitedDueToGasLimit;
  }

  



  function totalStakedFor(address addr) public view returns(uint256) {
    return tokenEscrow.depositsOf(addr);
  }

  



  function hasEnoughStake(address addr) public view returns(bool) {
    return tokenEscrow.hasEnoughStake(addr);
  }

  


  function getMinAuditStake() public view returns(uint256) {
    return tokenEscrow.minAuditStake();
  }

  


  function getAuditTimeoutInBlocks() public view returns(uint256) {
    return auditData.auditTimeoutInBlocks();
  }

  


  function getMinAuditPrice (address auditor) public view returns(uint256) {
    return auditData.getMinAuditPrice(auditor);
  }

  


  function getMaxAssignedRequests() public view returns(uint256) {
    return auditData.maxAssignedRequests();
  }

  


  function anyRequestAvailable() public view returns(AuditAvailabilityState) {
    uint256 requestId;

    
    if (!hasEnoughStake(msg.sender)) {
      return AuditAvailabilityState.Understaked;
    }

    
    if (!auditQueueExists()) {
      return AuditAvailabilityState.Empty;
    }

    
    if (assignedRequestCount[msg.sender] >= auditData.maxAssignedRequests()) {
      return AuditAvailabilityState.Exceeded;
    }

    requestId = anyAuditRequestMatchesPrice(auditData.getMinAuditPrice(msg.sender));
    if (requestId == 0) {
      return AuditAvailabilityState.Underpriced;
    }
    return AuditAvailabilityState.Ready;
  }

  



  function getNextPoliceAssignment() public view returns (bool, uint256, uint256, string, uint256) {
    return police.getNextPoliceAssignment(msg.sender);
  }

  


  
  function getNextAuditRequest() public {
    
    if (assignedAudits.listExists()) {
      bool exists;
      uint256 potentialExpiredRequestId;
      (exists, potentialExpiredRequestId) = assignedAudits.getAdjacent(HEAD, NEXT);
      uint256 allowanceBlockNumber = auditData.getAuditAssignBlockNumber(potentialExpiredRequestId) + auditData.auditTimeoutInBlocks();
      if (allowanceBlockNumber < block.number) {
        updateAssignedAudits(potentialExpiredRequestId);
        auditData.setAuditState(potentialExpiredRequestId, QuantstampAuditData.AuditState.Expired);
        emit LogAuditAssignmentUpdate_Expired(potentialExpiredRequestId, allowanceBlockNumber);
      }
    }

    AuditAvailabilityState isRequestAvailable = anyRequestAvailable();
    
    if (isRequestAvailable == AuditAvailabilityState.Empty) {
      emit LogAuditQueueIsEmpty();
      return;
    }

    
    if (isRequestAvailable == AuditAvailabilityState.Exceeded) {
      emit LogAuditAssignmentError_ExceededMaxAssignedRequests(msg.sender);
      return;
    }

    uint256 minPrice = auditData.getMinAuditPrice(msg.sender);
    require(minPrice >= minAuditPriceLowerCap);

    
    if (isRequestAvailable == AuditAvailabilityState.Understaked) {
      emit LogAuditAssignmentError_Understaked(msg.sender, totalStakedFor(msg.sender));
      return;
    }

    
    uint256 requestId = dequeueAuditRequest(minPrice);
    if (requestId == 0) {
      emit LogAuditNodePriceHigherThanRequests(msg.sender, minPrice);
      return;
    }

    auditData.setAuditState(requestId, QuantstampAuditData.AuditState.Assigned);
    auditData.setAuditAuditor(requestId, msg.sender);
    auditData.setAuditAssignBlockNumber(requestId, block.number);
    assignedRequestCount[msg.sender]++;
    
    assignedAudits.push(requestId, PREV);

    
    tokenEscrow.lockFunds(msg.sender, block.number.add(auditData.auditTimeoutInBlocks()).add(police.policeTimeoutInBlocks()));

    mostRecentAssignedRequestIdsPerAuditor[msg.sender] = requestId;
    emit LogAuditAssigned(requestId,
      auditData.getAuditAuditor(requestId),
      auditData.getAuditRequestor(requestId),
      auditData.getAuditContractUri(requestId),
      auditData.getAuditPrice(requestId),
      auditData.getAuditRequestBlockNumber(requestId));
  }
  

  



  function setAuditNodePrice(uint256 price) public {
    require(price >= minAuditPriceLowerCap);
    require(price <= auditData.token().totalSupply());
    auditData.setMinAuditPrice(msg.sender, price);
    emit LogAuditNodePriceChanged(msg.sender, price);
  }

  



  function isAuditFinished(uint256 requestId) public view returns(bool) {
    QuantstampAuditData.AuditState state = auditData.getAuditState(requestId);
    return state == QuantstampAuditData.AuditState.Completed || state == QuantstampAuditData.AuditState.Error;
  }

  




  function getNextPrice(uint256 price) public view returns(uint256) {
    bool exists;
    uint256 next;
    (exists, next) = priceList.getAdjacent(price, NEXT);
    return next;
  }

  




  function getNextAssignedRequest(uint256 requestId) public view returns(uint256) {
    bool exists;
    uint256 next;
    (exists, next) = assignedAudits.getAdjacent(requestId, NEXT);
    return next;
  }

  



  function myMostRecentAssignedAudit() public view returns(
    uint256, 
    address, 
    string,  
    uint256, 
    uint256  
  ) {
    uint256 requestId = mostRecentAssignedRequestIdsPerAuditor[msg.sender];
    return (
      requestId,
      auditData.getAuditRequestor(requestId),
      auditData.getAuditContractUri(requestId),
      auditData.getAuditPrice(requestId),
      auditData.getAuditRequestBlockNumber(requestId)
    );
  }

  






  function getNextAuditByPrice(uint256 price, uint256 requestId) public view returns(uint256) {
    bool exists;
    uint256 next;
    (exists, next) = auditsByPrice[price].getAdjacent(requestId, NEXT);
    return next;
  }

  



  function findPrecedingPrice(uint256 price) public view returns(uint256) {
    return priceList.getSortedSpot(HEAD, price, NEXT);
  }

  




  function updateAssignedAudits(uint256 requestId) internal {
    assignedAudits.remove(requestId);
    assignedRequestCount[auditData.getAuditAuditor(requestId)] =
      assignedRequestCount[auditData.getAuditAuditor(requestId)].sub(1);
  }

  


  function auditQueueExists() internal view returns(bool) {
    return priceList.listExists();
  }

  




  function queueAuditRequest(uint256 requestId, uint256 existingPrice) internal {
    uint256 price = auditData.getAuditPrice(requestId);
    if (!priceList.nodeExists(price)) {
      uint256 priceHint = priceList.nodeExists(existingPrice) ? existingPrice : HEAD;
      
      priceList.insert(priceList.getSortedSpot(priceHint, price, NEXT), price, PREV);
    }
    
    auditsByPrice[price].push(requestId, PREV);
  }

  





  function anyAuditRequestMatchesPrice(uint256 minPrice) internal view returns(uint256) {
    bool priceExists;
    uint256 price;
    uint256 requestId;

    
    (priceExists, price) = priceList.getAdjacent(HEAD, PREV);
    if (price < minPrice) {
      return 0;
    }
    requestId = getNextAuditByPrice(price, HEAD);
    return requestId;
  }

  



  function dequeueAuditRequest(uint256 minPrice) internal returns(uint256) {

    uint256 requestId;
    uint256 price;

    
    
    
    
    requestId = anyAuditRequestMatchesPrice(minPrice);

    if (requestId > 0) {
      price = auditData.getAuditPrice(requestId);
      auditsByPrice[price].remove(requestId);
      
      if (!auditsByPrice[price].listExists()) {
        priceList.remove(price);
      }
      return requestId;
    }
    return 0;
  }

  



  function removeQueueElement(uint256 requestId) internal {
    uint256 price = auditData.getAuditPrice(requestId);

    
    require(priceList.nodeExists(price));
    require(auditsByPrice[price].nodeExists(requestId));

    auditsByPrice[price].remove(requestId);
    if (!auditsByPrice[price].listExists()) {
      priceList.remove(price);
    }
  }

  



  function transferReward (uint256 requestId) internal {
    uint256 auditPoliceFee = police.collectedFees(requestId);
    uint256 auditorPayment = auditData.getAuditPrice(requestId).sub(auditPoliceFee);
    safeTransferFromDataContract(msg.sender, auditorPayment);
    emit LogPayAuditor(requestId, msg.sender, auditorPayment);
  }

  




  function safeTransferFromDataContract(address _to, uint256 amount) internal {
    auditData.approveWhitelisted(amount);
    require(auditData.token().transferFrom(address(auditData), _to, amount));
  }
}