

pragma solidity ^0.4.25;



contract DaoCommon is DaoCommonMini {

    using MathHelper for MathHelper;

    



    function isFromProposer(bytes32 _proposalId)
        internal
        view
        returns (bool _isFromProposer)
    {
        _isFromProposer = msg.sender == daoStorage().readProposalProposer(_proposalId);
    }

    




    function isEditable(bytes32 _proposalId)
        internal
        view
        returns (bool _isEditable)
    {
        bytes32 _finalVersion;
        (,,,,,,,_finalVersion,,) = daoStorage().readProposal(_proposalId);
        _isEditable = _finalVersion == EMPTY_BYTES;
    }

    


    function weiInDao()
        internal
        view
        returns (uint256 _wei)
    {
        _wei = get_contract(CONTRACT_DAO_FUNDING_MANAGER).balance;
    }

    


    modifier ifAfterDraftVotingPhase(bytes32 _proposalId) {
        uint256 _start = daoStorage().readProposalDraftVotingTime(_proposalId);
        require(_start > 0); 
        require(now >= _start.add(getUintConfig(CONFIG_DRAFT_VOTING_PHASE)));
        _;
    }

    modifier ifCommitPhase(bytes32 _proposalId, uint8 _index) {
        requireInPhase(
            daoStorage().readProposalVotingTime(_proposalId, _index),
            0,
            getUintConfig(_index == 0 ? CONFIG_VOTING_COMMIT_PHASE : CONFIG_INTERIM_COMMIT_PHASE)
        );
        _;
    }

    modifier ifRevealPhase(bytes32 _proposalId, uint256 _index) {
      requireInPhase(
          daoStorage().readProposalVotingTime(_proposalId, _index),
          getUintConfig(_index == 0 ? CONFIG_VOTING_COMMIT_PHASE : CONFIG_INTERIM_COMMIT_PHASE),
          getUintConfig(_index == 0 ? CONFIG_VOTING_PHASE_TOTAL : CONFIG_INTERIM_PHASE_TOTAL)
      );
      _;
    }

    modifier ifAfterProposalRevealPhase(bytes32 _proposalId, uint256 _index) {
      uint256 _start = daoStorage().readProposalVotingTime(_proposalId, _index);
      require(_start > 0);
      require(now >= _start.add(getUintConfig(_index == 0 ? CONFIG_VOTING_PHASE_TOTAL : CONFIG_INTERIM_PHASE_TOTAL)));
      _;
    }

    modifier ifDraftVotingPhase(bytes32 _proposalId) {
        requireInPhase(
            daoStorage().readProposalDraftVotingTime(_proposalId),
            0,
            getUintConfig(CONFIG_DRAFT_VOTING_PHASE)
        );
        _;
    }

    modifier isProposalState(bytes32 _proposalId, bytes32 _STATE) {
        bytes32 _currentState;
        (,,,_currentState,,,,,,) = daoStorage().readProposal(_proposalId);
        require(_currentState == _STATE);
        _;
    }

    


    modifier ifFundingPossible(uint256[] _fundings, uint256 _finalReward) {
        require(MathHelper.sumNumbers(_fundings).add(_finalReward) <= weiInDao());
        _;
    }

    modifier ifDraftNotClaimed(bytes32 _proposalId) {
        require(daoStorage().isDraftClaimed(_proposalId) == false);
        _;
    }

    modifier ifNotClaimed(bytes32 _proposalId, uint256 _index) {
        require(daoStorage().isClaimed(_proposalId, _index) == false);
        _;
    }

    modifier ifNotClaimedSpecial(bytes32 _proposalId) {
        require(daoSpecialStorage().isClaimed(_proposalId) == false);
        _;
    }

    modifier hasNotRevealed(bytes32 _proposalId, uint256 _index) {
        uint256 _voteWeight;
        (, _voteWeight) = daoStorage().readVote(_proposalId, _index, msg.sender);
        require(_voteWeight == uint(0));
        _;
    }

    modifier hasNotRevealedSpecial(bytes32 _proposalId) {
        uint256 _weight;
        (,_weight) = daoSpecialStorage().readVote(_proposalId, msg.sender);
        require(_weight == uint256(0));
        _;
    }

    modifier ifAfterRevealPhaseSpecial(bytes32 _proposalId) {
      uint256 _start = daoSpecialStorage().readVotingTime(_proposalId);
      require(_start > 0);
      require(now.sub(_start) >= getUintConfig(CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL));
      _;
    }

    modifier ifCommitPhaseSpecial(bytes32 _proposalId) {
        requireInPhase(
            daoSpecialStorage().readVotingTime(_proposalId),
            0,
            getUintConfig(CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE)
        );
        _;
    }

    modifier ifRevealPhaseSpecial(bytes32 _proposalId) {
        requireInPhase(
            daoSpecialStorage().readVotingTime(_proposalId),
            getUintConfig(CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE),
            getUintConfig(CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL)
        );
        _;
    }

    function daoWhitelistingStorage()
        internal
        view
        returns (DaoWhitelistingStorage _contract)
    {
        _contract = DaoWhitelistingStorage(get_contract(CONTRACT_STORAGE_DAO_WHITELISTING));
    }

    function getAddressConfig(bytes32 _configKey)
        public
        view
        returns (address _configValue)
    {
        _configValue = daoConfigsStorage().addressConfigs(_configKey);
    }

    function getBytesConfig(bytes32 _configKey)
        public
        view
        returns (bytes32 _configValue)
    {
        _configValue = daoConfigsStorage().bytesConfigs(_configKey);
    }

    


    function isParticipant(address _user)
        public
        view
        returns (bool _is)
    {
        _is =
            (daoRewardsStorage().lastParticipatedQuarter(_user) == currentQuarterNumber())
            && (daoStakeStorage().lockedDGDStake(_user) >= getUintConfig(CONFIG_MINIMUM_LOCKED_DGD));
    }

    


    function isModerator(address _user)
        public
        view
        returns (bool _is)
    {
        _is =
            (daoRewardsStorage().lastParticipatedQuarter(_user) == currentQuarterNumber())
            && (daoStakeStorage().lockedDGDStake(_user) >= getUintConfig(CONFIG_MINIMUM_DGD_FOR_MODERATOR))
            && (daoPointsStorage().getReputation(_user) >= getUintConfig(CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR));
    }

    






    function startOfMilestone(bytes32 _proposalId, uint256 _milestoneIndex)
        internal
        view
        returns (uint256 _milestoneStart)
    {
        uint256 _startOfPrecedingVotingRound = daoStorage().readProposalVotingTime(_proposalId, _milestoneIndex);
        require(_startOfPrecedingVotingRound > 0);
        

        if (_milestoneIndex == 0) { 
            _milestoneStart =
                _startOfPrecedingVotingRound
                .add(getUintConfig(CONFIG_VOTING_PHASE_TOTAL));
        } else { 
            _milestoneStart =
                _startOfPrecedingVotingRound
                .add(getUintConfig(CONFIG_INTERIM_PHASE_TOTAL));
        }
    }

    




    function getTimelineForNextVote(
        uint256 _index,
        uint256 _tentativeVotingStart
    )
        internal
        view
        returns (uint256 _actualVotingStart)
    {
        uint256 _timeLeftInQuarter = getTimeLeftInQuarter(_tentativeVotingStart);
        uint256 _votingDuration = getUintConfig(_index == 0 ? CONFIG_VOTING_PHASE_TOTAL : CONFIG_INTERIM_PHASE_TOTAL);
        _actualVotingStart = _tentativeVotingStart;
        if (timeInQuarter(_tentativeVotingStart) < getUintConfig(CONFIG_LOCKING_PHASE_DURATION)) { 
            _actualVotingStart = _tentativeVotingStart.add(
                getUintConfig(CONFIG_LOCKING_PHASE_DURATION).sub(timeInQuarter(_tentativeVotingStart))
            );
        } else if (_timeLeftInQuarter < _votingDuration.add(getUintConfig(CONFIG_VOTE_CLAIMING_DEADLINE))) { 
            _actualVotingStart = _tentativeVotingStart.add(
                _timeLeftInQuarter.add(getUintConfig(CONFIG_LOCKING_PHASE_DURATION)).add(1)
            );
        }
    }

    



    function checkNonDigixProposalLimit(bytes32 _proposalId)
        internal
        view
    {
        require(isNonDigixProposalsWithinLimit(_proposalId));
    }

    function isNonDigixProposalsWithinLimit(bytes32 _proposalId)
        internal
        view
        returns (bool _withinLimit)
    {
        bool _isDigixProposal;
        (,,,,,,,,,_isDigixProposal) = daoStorage().readProposal(_proposalId);
        _withinLimit = true;
        if (!_isDigixProposal) {
            _withinLimit = daoProposalCounterStorage().proposalCountByQuarter(currentQuarterNumber()) < getUintConfig(CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER);
        }
    }

    



    function checkNonDigixFundings(uint256[] _milestonesFundings, uint256 _finalReward)
        internal
        view
    {
        if (!is_founder()) {
            require(_milestonesFundings.length <= getUintConfig(CONFIG_MAX_MILESTONES_FOR_NON_DIGIX));
            require(MathHelper.sumNumbers(_milestonesFundings).add(_finalReward) <= getUintConfig(CONFIG_MAX_FUNDING_FOR_NON_DIGIX));
        }
    }

    



    function senderCanDoProposerOperations()
        internal
        view
    {
        require(isMainPhase());
        require(isParticipant(msg.sender));
        require(identity_storage().is_kyc_approved(msg.sender));
    }
}


pragma solidity ^0.4.25;



