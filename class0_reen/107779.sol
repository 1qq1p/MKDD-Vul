


pragma solidity ^0.5.2;






contract AbsoluteVote is IntVoteInterface {
    using SafeMath for uint;

    struct Parameters {
        uint256 precReq; 
        address voteOnBehalf; 
                              
    }

    struct Voter {
        uint256 vote; 
        uint256 reputation; 
    }

    struct Proposal {
        bytes32 organizationId; 
        bool open; 
        address callbacks;
        uint256 numOfChoices;
        bytes32 paramsHash; 
        uint256 totalVotes;
        mapping(uint=>uint) votes;
        mapping(address=>Voter) voters;
    }

    event AVVoteProposal(bytes32 indexed _proposalId, bool _isProxyVote);

    mapping(bytes32=>Parameters) public parameters;  
    mapping(bytes32=>Proposal) public proposals; 
    mapping(bytes32=>address) public organizations;

    uint256 public constant MAX_NUM_OF_CHOICES = 10;
    uint256 public proposalsCnt; 

  


    modifier votable(bytes32 _proposalId) {
        require(proposals[_proposalId].open);
        _;
    }

    







    function propose(uint256 _numOfChoices, bytes32 _paramsHash, address, address _organization)
        external
        returns(bytes32)
    {
        
        require(parameters[_paramsHash].precReq > 0);
        require(_numOfChoices > 0 && _numOfChoices <= MAX_NUM_OF_CHOICES);
        
        bytes32 proposalId = keccak256(abi.encodePacked(this, proposalsCnt));
        proposalsCnt = proposalsCnt.add(1);
        
        Proposal memory proposal;
        proposal.numOfChoices = _numOfChoices;
        proposal.paramsHash = _paramsHash;
        proposal.callbacks = msg.sender;
        proposal.organizationId = keccak256(abi.encodePacked(msg.sender, _organization));
        proposal.open = true;
        proposals[proposalId] = proposal;
        if (organizations[proposal.organizationId] == address(0)) {
            if (_organization == address(0)) {
                organizations[proposal.organizationId] = msg.sender;
            } else {
                organizations[proposal.organizationId] = _organization;
            }
        }
        emit NewProposal(proposalId, organizations[proposal.organizationId], _numOfChoices, msg.sender, _paramsHash);
        return proposalId;
    }

    








    function vote(
        bytes32 _proposalId,
        uint256 _vote,
        uint256 _amount,
        address _voter)
        external
        votable(_proposalId)
        returns(bool)
        {

        Proposal storage proposal = proposals[_proposalId];
        Parameters memory params = parameters[proposal.paramsHash];
        address voter;
        if (params.voteOnBehalf != address(0)) {
            require(msg.sender == params.voteOnBehalf);
            voter = _voter;
        } else {
            voter = msg.sender;
        }
        return internalVote(_proposalId, voter, _vote, _amount);
    }

  




    function cancelVote(bytes32 _proposalId) external votable(_proposalId) {
        cancelVoteInternal(_proposalId, msg.sender);
    }

    





    function execute(bytes32 _proposalId) external votable(_proposalId) returns(bool) {
        return _execute(_proposalId);
    }

  





    function getNumberOfChoices(bytes32 _proposalId) external view returns(uint256) {
        return proposals[_proposalId].numOfChoices;
    }

  






    function voteInfo(bytes32 _proposalId, address _voter) external view returns(uint, uint) {
        Voter memory voter = proposals[_proposalId].voters[_voter];
        return (voter.vote, voter.reputation);
    }

    





    function voteStatus(bytes32 _proposalId, uint256 _choice) external view returns(uint256) {
        return proposals[_proposalId].votes[_choice];
    }

    




    function isVotable(bytes32 _proposalId) external view returns(bool) {
        return  proposals[_proposalId].open;
    }

    



    function isAbstainAllow() external pure returns(bool) {
        return true;
    }

    




    function getAllowedRangeOfChoices() external pure returns(uint256 min, uint256 max) {
        return (0, MAX_NUM_OF_CHOICES);
    }

    


    function setParameters(uint256 _precReq, address _voteOnBehalf) public returns(bytes32) {
        require(_precReq <= 100 && _precReq > 0);
        bytes32 hashedParameters = getParametersHash(_precReq, _voteOnBehalf);
        parameters[hashedParameters] = Parameters({
            precReq: _precReq,
            voteOnBehalf: _voteOnBehalf
        });
        return hashedParameters;
    }

    


    function getParametersHash(uint256 _precReq, address _voteOnBehalf) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_precReq, _voteOnBehalf));
    }

    function cancelVoteInternal(bytes32 _proposalId, address _voter) internal {
        Proposal storage proposal = proposals[_proposalId];
        Voter memory voter = proposal.voters[_voter];
        proposal.votes[voter.vote] = (proposal.votes[voter.vote]).sub(voter.reputation);
        proposal.totalVotes = (proposal.totalVotes).sub(voter.reputation);
        delete proposal.voters[_voter];
        emit CancelVoting(_proposalId, organizations[proposal.organizationId], _voter);
    }

    function deleteProposal(bytes32 _proposalId) internal {
        Proposal storage proposal = proposals[_proposalId];
        for (uint256 cnt = 0; cnt <= proposal.numOfChoices; cnt++) {
            delete proposal.votes[cnt];
        }
        delete proposals[_proposalId];
    }

    





    function _execute(bytes32 _proposalId) internal votable(_proposalId) returns(bool) {
        Proposal storage proposal = proposals[_proposalId];
        uint256 totalReputation =
        VotingMachineCallbacksInterface(proposal.callbacks).getTotalReputationSupply(_proposalId);
        uint256 precReq = parameters[proposal.paramsHash].precReq;
        
        for (uint256 cnt = 0; cnt <= proposal.numOfChoices; cnt++) {
            if (proposal.votes[cnt] > (totalReputation/100)*precReq) {
                Proposal memory tmpProposal = proposal;
                deleteProposal(_proposalId);
                emit ExecuteProposal(_proposalId, organizations[tmpProposal.organizationId], cnt, totalReputation);
                return ProposalExecuteInterface(tmpProposal.callbacks).executeProposal(_proposalId, int(cnt));
            }
        }
        return false;
    }

    








    function internalVote(bytes32 _proposalId, address _voter, uint256 _vote, uint256 _rep) internal returns(bool) {
        Proposal storage proposal = proposals[_proposalId];
        
        require(_vote <= proposal.numOfChoices);
        
        uint256 reputation = VotingMachineCallbacksInterface(proposal.callbacks).reputationOf(_voter, _proposalId);
        require(reputation > 0, "_voter must have reputation");
        require(reputation >= _rep);
        uint256 rep = _rep;
        if (rep == 0) {
            rep = reputation;
        }
        
        if (proposal.voters[_voter].reputation != 0) {
            cancelVoteInternal(_proposalId, _voter);
        }
        
        proposal.votes[_vote] = rep.add(proposal.votes[_vote]);
        proposal.totalVotes = rep.add(proposal.totalVotes);
        proposal.voters[_voter] = Voter({
            reputation: rep,
            vote: _vote
        });
        
        emit VoteProposal(_proposalId, organizations[proposal.organizationId], _voter, _vote, rep);
        emit AVVoteProposal(_proposalId, (_voter != msg.sender));
        
        return _execute(_proposalId);
    }
}
