pragma solidity ^0.5.0;


























contract TokenListingManager is Ownable {

    address public constant NECTAR_TOKEN = 0xCc80C051057B774cD75067Dc48f8987C4Eb97A5e;
    address public constant TOKEN_FACTORY = 0x8936131A81F29205EeDDec486f401A8A0aFAb15A;
    uint public constant MAX_CANDIDATES = 20;

    struct TokenProposal {
        address[] consideredTokens;
        uint startBlock;
        uint startTime;
        uint duration;
        DestructibleMiniMeToken votingToken;
        uint[] yesVotes;
        
        
        
        
        uint criteria;
        uint extraData;
        bool concluded;
        mapping(address => mapping(address => uint256)) votesForToken;
    }

    TokenProposal[] public tokenBatches;

    DestructibleMiniMeTokenFactory public tokenFactory;
    address payable public nectarToken;
    mapping(address => bool) public admins;

    mapping(address => bool) public isWinner;
    mapping(address => uint256) public winningVotes;
    mapping(address => uint) public proposalWhenTokenWon;

    modifier onlyAdmins() {
        require(isAdmin(msg.sender));
        _;
    }

    constructor(address _tokenFactory, address payable _nectarToken) public {
        tokenFactory = DestructibleMiniMeTokenFactory(_tokenFactory);
        nectarToken = _nectarToken;
        admins[msg.sender] = true;
    }

    
    
    
    
    
    function startTokenVotes(address[] memory _tokens, uint _duration, uint _criteria, uint _extraData) public onlyAdmins {
        require(_tokens.length <= MAX_CANDIDATES);

        if (_criteria == 1) {
            
            require(_extraData < _tokens.length);
        }

        uint _proposalId = tokenBatches.length;
        if (_proposalId > 0) {
          endTokenVote(_proposalId - 1);
        }
        tokenBatches.length++;
        TokenProposal storage p = tokenBatches[_proposalId];
        p.duration = _duration * (1 days);

        p.consideredTokens = _tokens;
        p.yesVotes = new uint[](_tokens.length);

        p.votingToken = tokenFactory.createDestructibleCloneToken(
                nectarToken,
                getBlockNumber(),
                appendUintToString("EfxTokenVotes-", _proposalId),
                MiniMeToken(nectarToken).decimals(),
                appendUintToString("EVT-", _proposalId),
                true);

        p.startTime = now;
        p.startBlock = getBlockNumber();
        p.criteria = _criteria;
        p.extraData = _extraData;
        p.concluded = false;

        emit NewTokens(_proposalId);
    }


    
    function endTokenVote(uint _proposalId) public returns(bool) {

        require(_proposalId <= tokenBatches.length);

        TokenProposal storage op = tokenBatches[_proposalId];
        require(op.startTime + op.duration < now);
        if (op.concluded) {
          return true;
        }

        uint[] memory _previousWinnerMap = getWinnerIndices(_proposalId);
        for (uint i=0; i < _previousWinnerMap.length; i++) {
            isWinner[op.consideredTokens[_previousWinnerMap[i]]] = true;
            winningVotes[op.consideredTokens[_previousWinnerMap[i]]] = op.yesVotes[_previousWinnerMap[i]];
            proposalWhenTokenWon[op.consideredTokens[_previousWinnerMap[i]]] = _proposalId;
        }

        DestructibleMiniMeToken(op.votingToken).recycle();
        op.concluded = true;
        return true;
    }

    
    
    
    function vote(uint _proposalId, uint _tokenIndex, uint _amount) public {
        
        require(tokenBatches.length > 0);
        require(_proposalId == tokenBatches.length - 1);
        require(_tokenIndex < 12);

        TokenProposal storage p = tokenBatches[_proposalId];

        require(now < p.startTime + (p.duration / 2));

        uint amount = DestructibleMiniMeToken(p.votingToken).balanceOf(msg.sender);
        require(amount >= _amount);

        uint weightedAmount = getFactor(_amount);

        require(DestructibleMiniMeToken(p.votingToken).transferFrom(msg.sender, address(this), _amount));

        tokenBatches[_proposalId].yesVotes[_tokenIndex] += weightedAmount;
        p.votesForToken[tokenBatches[_proposalId].consideredTokens[_tokenIndex]][msg.sender] += weightedAmount;

        emit Vote(_proposalId, msg.sender, tokenBatches[_proposalId].consideredTokens[_tokenIndex], weightedAmount);
    }

    function getFactor(uint _amount) view public returns (uint weighted) {
      uint currentRound = tokenBatches.length - 1;
      TokenProposal memory p = tokenBatches[currentRound];
      if ((now - p.startTime) > (p.duration / 2)) {
          weighted = 2;
      } else {
          weighted = 2 * _amount - ((now - p.startTime) * _amount / (p.duration / 2));
      }
    }

    function getWinnerIndices(uint _proposalId) public view returns(uint[] memory winners) {
        require(_proposalId < tokenBatches.length);

        TokenProposal memory p = tokenBatches[_proposalId];

        
        if (p.criteria == 0) {
            winners = new uint[](1);
            uint max = 0;

            for (uint i=0; i < p.consideredTokens.length; i++) {
                if (p.yesVotes[i] > p.yesVotes[max]) {
                    max = i;
                }
            }

            winners[0] = max;
        }

        
        if (p.criteria == 1) {
            uint[] memory indexesWithMostVotes = new uint[](p.extraData);
            winners = new uint[](p.extraData);

            
            
            for (uint i = 0; i < p.consideredTokens.length; i++) {
                uint last = p.extraData - 1;
                if (p.yesVotes[i] > p.yesVotes[indexesWithMostVotes[last]]) {
                    indexesWithMostVotes[last] = i;

                    for (uint j=last; j > 0; j--) {
                        if (p.yesVotes[indexesWithMostVotes[j]] > p.yesVotes[indexesWithMostVotes[j-1]]) {
                            uint help = indexesWithMostVotes[j];
                            indexesWithMostVotes[j] = indexesWithMostVotes[j-1];
                            indexesWithMostVotes[j-1] = help;
                        }
                    }
                }
            }

            for (uint i = 0; i < p.extraData; i++) {
                winners[i] = indexesWithMostVotes[i];
            }
        }

        
        if (p.criteria == 2) {
            uint numOfTokens = 0;
            for (uint i = 0; i < p.consideredTokens.length; i++) {
                if (p.yesVotes[i] > p.extraData) {
                    numOfTokens++;
                }
            }

            winners = new uint[](numOfTokens);
            uint count = 0;
            for (uint i = 0; i < p.consideredTokens.length; i++) {
                if (p.yesVotes[i] > p.extraData) {
                    winners[count] = i;
                    count++;
                }
            }
        }
    }

    function getWinners() public view returns(address[] memory) {
        if(tokenBatches.length == 0) {
            return new address[](0);
        }

        uint[] memory winnerIndices = getWinnerIndices(tokenBatches.length - 1);

        TokenProposal memory p = tokenBatches[tokenBatches.length - 1];

        address[] memory winners = new address[](winnerIndices.length);
        for (uint i = 0; i < winnerIndices.length; i++) {
            winners[i] = p.consideredTokens[winnerIndices[i]];
        }
    }

    function getUserVotesForWinner(address _token, address _voter) external view returns(uint256) {
      uint roundWhenWon = proposalWhenTokenWon[_token];
      return tokenBatches[roundWhenWon].votesForToken[_token][_voter];
    }

    
    function numberOfProposals() public view returns(uint) {
        return tokenBatches.length;
    }

    
    
    function addAdmin(address _newAdmin) public onlyAdmins {
        admins[_newAdmin] = true;
    }

    
    
    function removeAdmin(address _admin) public onlyOwner {
        admins[_admin] = false;
    }

    
    
    function proposal(uint _proposalId) public view returns(
        uint _startBlock,
        uint _startTime,
        uint _duration,
        bool _active,
        bool _finalized,
        uint[] memory _votes,
        address[] memory _tokens,
        address _votingToken,
        bool _hasBalance
    ) {
        require(_proposalId < tokenBatches.length);

        TokenProposal memory p = tokenBatches[_proposalId];
        _startBlock = p.startBlock;
        _startTime = p.startTime;
        _duration = p.duration;
        _finalized = (_startTime+_duration < now);
        _active = !_finalized && (p.startBlock < getBlockNumber());
        _votes = p.yesVotes;
        _tokens = p.consideredTokens;
        _votingToken = address(p.votingToken);
        _hasBalance = (_votingToken == address(0)) ? false : (DestructibleMiniMeToken(p.votingToken).balanceOf(msg.sender) > 0);
    }

    function isAdmin(address _admin) public view returns(bool) {
        return admins[_admin];
    }

    function proxyPayment(address ) public payable returns(bool) {
        return false;
    }

    function onTransfer(address, address, uint ) public pure returns(bool) {
        return true;
    }

    function onApprove(address, address, uint ) public pure returns(bool) {
        return true;
    }

    function getBlockNumber() internal view returns (uint) {
        return block.number;
    }

    function appendUintToString(string memory inStr, uint _i) internal pure returns (string memory _str) {
    if (_i == 0) {
        return "0";
    }
    uint j = _i;
    uint len;
    while (j != 0) {
        len++;
        j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len - 1;
    while (_i != 0) {
        bstr[k--] = byte(uint8(48 + _i % 10));
        _i /= 10;
    }

    return string(abi.encodePacked(inStr, string(bstr)));
    }

    event Vote(uint indexed idProposal, address indexed _voter, address chosenToken, uint amount);
    event NewTokens(uint indexed idProposal);
}