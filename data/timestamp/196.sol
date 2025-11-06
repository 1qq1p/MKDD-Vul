pragma solidity ^0.4.19;


contract Tournament is PVP {

    uint256 internal constant GROUP_SIZE = 5;
    uint256 internal constant DATA_SIZE = 2;
    uint256 internal constant THRESHOLD = 300;
    
  


    uint256[160] public tournamentQueue;
    
    


    uint256 internal tournamentEntranceFeeCut = 100;
    
    
    uint256 public tournamentOwnersCut;
    uint256 public tournamentIncentiveCut;
    
     




    event TournamentNewContender(address owner, uint256 warriorIds, uint256 entranceFee);
    
    





    event TournamentFinished(uint256[] owners, uint32[] results, uint256 tournamentBank);
    
    function Tournament(uint256 _pvpCut, uint256 _tournamentBankCut, 
    uint256 _pvpMaxIncentiveCut, uint256 _tournamentOwnersCut, uint256 _tournamentIncentiveCut) public
    PVP(_pvpCut, _tournamentBankCut, _pvpMaxIncentiveCut) 
    {
        require((_tournamentOwnersCut + _tournamentIncentiveCut) <= 10000);
		
		tournamentOwnersCut = _tournamentOwnersCut;
		tournamentIncentiveCut = _tournamentIncentiveCut;
    }
    
    
    
    
    
    function _computeTournamentIncentiveReward(uint256 _currentBank, uint256 _incentiveCut) internal pure returns (uint256){
        
        
        
        
        return _currentBank * _incentiveCut / 10000;
    }
    
    function _computeTournamentContenderCut(uint256 _incentiveCut) internal view returns (uint256) {
        
        
        
        return 10000 - tournamentOwnersCut - _incentiveCut;
    }
    
    function _computeTournamentBeneficiaryFee(uint256 _currentBank) internal view returns (uint256){
        
        
        
        
        return _currentBank * tournamentOwnersCut / 10000;
    }
    
    
    
    
    function setTournamentEntranceFeeCut(uint256 _cut) external onlyOwner {
        
        require(_cut <= 10000);
        
        require(tournamentQueueSize == 0);
        
		tournamentEntranceFeeCut = _cut;
    }
    
    function getTournamentEntranceFee() external view returns(uint256) {
        return currentTournamentBank * tournamentEntranceFeeCut / 10000;
    }
    
    
    function getTournamentThresholdFee() public view returns(uint256) {
        return currentTournamentBank * tournamentEntranceFeeCut * (10000 - THRESHOLD) / 10000 / 10000;
    }
    
    
    function maxTournamentContenders() public view returns(uint256){
        return tournamentQueue.length / DATA_SIZE;
    }
    
    function canFinishTournament() external view returns(bool) {
        return tournamentEndBlock <= block.number && tournamentQueueSize > 0;
    }
    
    
    
    function _triggerNewTournamentContender(address _owner, uint256[] memory _tournamentData, uint256 _fee) internal {
        
        
        currentTournamentBank += _fee;
        
        uint256 packedWarriorIds = CryptoUtils._packWarriorIds(_tournamentData);
        
        uint256 combinedWarrior = CryptoUtils._combineWarriors(_tournamentData);
        
        
        
        uint256 size = tournamentQueueSize++ * DATA_SIZE;
        
		tournamentQueue[size++] = packedWarriorIds;
		tournamentQueue[size++] = combinedWarrior;
		warriorToOwner[CryptoUtils._unpackWarriorId(packedWarriorIds, 0)] = _owner;
		
		
		TournamentNewContender(_owner, packedWarriorIds, _fee);
    }
    
    function addTournamentContender(address _owner, uint256[] _tournamentData) external payable whenNotPaused{
        
        require(msg.sender == address(pvpListener));
        
        require(_owner != address(0));
        
        
        require(pvpBattleFee == 0 || currentTournamentBank > 0);
        
        
        uint256 fee = getTournamentThresholdFee();
        require(msg.value >= fee);
        
        require(ownerToBooty[_owner] == 0);
        
        
        require(_tournamentData.length == GROUP_SIZE);
        
        
        require(tournamentQueueSize < maxTournamentContenders());
        
        
        require(block.number >= getTournamentAdmissionBlock());
        
        require(block.number <= tournamentEndBlock);
        
        
        _triggerNewTournamentContender(_owner, _tournamentData, fee);
    }
    
    
    function getCombinedWarriors() internal view returns(uint256[] memory warriorsData) {
        uint256 length = tournamentQueueSize;
        warriorsData = new uint256[](length);
        
        for(uint256 i = 0; i < length; i ++) {
            
            warriorsData[i] = tournamentQueue[i * DATA_SIZE + 1];
        }
        return warriorsData;
    }
    
    function getTournamentState() external view returns
    (uint256 contendersCount, uint256 bank, uint256 admissionStartBlock, uint256 endBlock, uint256 incentiveReward)
    {
    	contendersCount = tournamentQueueSize;
    	bank = currentTournamentBank;
    	admissionStartBlock = getTournamentAdmissionBlock();   
    	endBlock = tournamentEndBlock;
    	incentiveReward = _computeTournamentIncentiveReward(bank, _computeIncentiveCut(bank, tournamentIncentiveCut));
    }
    
    function _repackToCombinedIds(uint256[] memory _warriorsData) internal view {
        uint256 length = _warriorsData.length;
        for(uint256 i = 0; i < length; i ++) {
            _warriorsData[i] = tournamentQueue[i * DATA_SIZE];
        }
    }
    
    
    
    function _computeTournamentBooty(uint256 _currentBank, uint256 _contenderResult, uint256 _totalBattles) internal pure returns (uint256){
        
        
        
        
        
        return _currentBank * _contenderResult / _totalBattles;
        
    }
    
    function _grandTournamentBooty(uint256 _warriorIds, uint256 _currentBank, uint256 _contenderResult, uint256 _totalBattles)
    internal returns (uint256)
    {
        uint256 warriorId = CryptoUtils._unpackWarriorId(_warriorIds, 0);
        address owner = warriorToOwner[warriorId];
        uint256 booty = _computeTournamentBooty(_currentBank, _contenderResult, _totalBattles);
        return sendBooty(owner, booty);
    }
    
    function _grandTournamentRewards(uint256 _currentBank, uint256[] memory _warriorsData, uint32[] memory _results) internal returns (uint256){
        uint256 length = _warriorsData.length;
        uint256 totalBattles = CryptoUtils._getTournamentBattles(length) * 10000;
        uint256 incentiveCut = _computeIncentiveCut(_currentBank, tournamentIncentiveCut);
        uint256 contenderCut = _computeTournamentContenderCut(incentiveCut);
        
        uint256 failedBooty = 0;
        for(uint256 i = 0; i < length; i ++) {
            
            failedBooty += _grandTournamentBooty(_warriorsData[i], _currentBank, _results[i] * contenderCut, totalBattles);
        }
        
        failedBooty += sendBooty(pvpListener.getBeneficiary(), _computeTournamentBeneficiaryFee(_currentBank));
        if (failedBooty > 0) {
            totalBooty += failedBooty;
        }
        return _computeTournamentIncentiveReward(_currentBank, incentiveCut);
    }
    
    function _repackToWarriorOwners(uint256[] memory warriorsData) internal view {
        uint256 length = warriorsData.length;
        for (uint256 i = 0; i < length; i ++) {
            warriorsData[i] = uint256(warriorToOwner[CryptoUtils._unpackWarriorId(warriorsData[i], 0)]);
        }
    }
    
    function _triggerFinishTournament() internal returns(uint256){
        
        uint256[] memory warriorsData = getCombinedWarriors();
        uint32[] memory results = CryptoUtils.getTournamentBattleResults(warriorsData, tournamentEndBlock - 1);
        
        _repackToCombinedIds(warriorsData);
        
        pvpListener.tournamentFinished(warriorsData);
        
        
        tournamentQueueSize = 0;
        
        _scheduleTournament();
        
        uint256 currentBank = currentTournamentBank;
        currentTournamentBank = 0;
        
        
        
        uint256 incentiveReward = _grandTournamentRewards(currentBank, warriorsData, results);
        
        currentTournamentBank = nextTournamentBank;
        nextTournamentBank = 0;
        
        _repackToWarriorOwners(warriorsData);
        
        
        TournamentFinished(warriorsData, results, currentBank);

        return incentiveReward;
    }
    
    function finishTournament() external whenNotPaused {
        
        
        require(tournamentEndBlock <= block.number);
        
        require(tournamentQueueSize > 0);
        
        uint256 incentiveReward = _triggerFinishTournament();
        
        
        safeSend(msg.sender, incentiveReward);
    }
    
    
    
    
    
    function removeAllTournamentContenders() external onlyOwner whenPaused {
        
        uint256 length = tournamentQueueSize;
        
        uint256 warriorId;
        uint256 failedBooty;
        uint256 i;

        uint256 fee;
        uint256 bank = currentTournamentBank;
        
        uint256[] memory warriorsData = new uint256[](length);
        
        for(i = 0; i < length; i ++) {
            warriorsData[i] = tournamentQueue[i * DATA_SIZE];
        }
        
        pvpListener.tournamentFinished(warriorsData);
        
     	currentTournamentBank = 0;
        tournamentQueueSize = 0;

        for(i = length - 1; i >= 0; i --) {
            
            warriorId = CryptoUtils._unpackWarriorId(warriorsData[i], 0);
            
			fee = bank - (bank * 10000 / (tournamentEntranceFeeCut * (10000 - THRESHOLD) / 10000 + 10000));
			
	        failedBooty += sendBooty(warriorToOwner[warriorId], fee);
	        
	        bank -= fee;
        }
        currentTournamentBank = bank;
        totalBooty += failedBooty;
    }
}
