pragma solidity ^0.4.24;

interface ConflictResolutionInterface {
    function minHouseStake(uint activeGames) external pure returns(uint);

    function maxBalance() external pure returns(int);

    function conflictEndFine() external pure returns(int);

    function isValidBet(uint8 _gameType, uint _betNum, uint _betValue) external pure returns(bool);

    function endGameConflict(
        uint8 _gameType,
        uint _betNum,
        uint _betValue,
        int _balance,
        uint _stake,
        bytes32 _serverSeed,
        bytes32 _userSeed
    )
        external
        view
        returns(int);

    function serverForceGameEnd(
        uint8 gameType,
        uint _betNum,
        uint _betValue,
        int _balance,
        uint _stake,
        uint _endInitiatedTime
    )
        external
        view
        returns(int);

    function userForceGameEnd(
        uint8 _gameType,
        uint _betNum,
        uint _betValue,
        int _balance,
        uint _stake,
        uint _endInitiatedTime
    )
        external
        view
        returns(int);
}

library MathUtil {
    




    function abs(int _val) internal pure returns(uint) {
        if (_val < 0) {
            return uint(-_val);
        } else {
            return uint(_val);
        }
    }

    


    function max(uint _val1, uint _val2) internal pure returns(uint) {
        return _val1 >= _val2 ? _val1 : _val2;
    }

    


    function min(uint _val1, uint _val2) internal pure returns(uint) {
        return _val1 <= _val2 ? _val1 : _val2;
    }
}

contract GameChannelBase is Destroyable, ConflictResolutionManager {
    using SafeCast for int;
    using SafeCast for uint;
    using SafeMath for int;
    using SafeMath for uint;


    
    enum GameStatus {
        ENDED, 
        ACTIVE, 
        USER_INITIATED_END, 
        SERVER_INITIATED_END 
    }

    
    enum ReasonEnded {
        REGULAR_ENDED, 
        SERVER_FORCED_END, 
        USER_FORCED_END, 
        CONFLICT_ENDED 
    }

    struct Game {
        
        GameStatus status;

        
        uint128 stake;

        
        
        uint8 gameType;
        uint32 roundId;
        uint betNum;
        uint betValue;
        int balance;
        bytes32 userSeed;
        bytes32 serverSeed;
        uint endInitiatedTime;
    }

    
    uint public constant MIN_TRANSFER_TIMESPAN = 1 days;

    
    uint public constant MAX_TRANSFER_TIMSPAN = 6 * 30 days;

    bytes32 public constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    bytes32 public constant BET_TYPEHASH = keccak256(
        "Bet(uint32 roundId,uint8 gameType,uint256 number,uint256 value,int256 balance,bytes32 serverHash,bytes32 userHash,uint256 gameId)"
    );

    bytes32 public DOMAIN_SEPERATOR;

    
    uint public activeGames = 0;

    
    
    uint public gameIdCntr = 1;

    
    address public serverAddress;

    
    address public houseAddress;

    
    uint public houseStake = 0;

    
    int public houseProfit = 0;

    
    uint128 public minStake;

    
    uint128 public maxStake;

    
    uint public profitTransferTimeSpan = 14 days;

    
    uint public lastProfitTransferTimestamp;

    
    mapping (uint => Game) public gameIdGame;

    
    mapping (address => uint) public userGameId;

    
    mapping (address => uint) public pendingReturns;

    
    modifier onlyValidHouseStake(uint _activeGames) {
        uint minHouseStake = conflictRes.minHouseStake(_activeGames);
        require(houseStake >= minHouseStake, "inv houseStake");
        _;
    }

    
    modifier onlyValidValue() {
        require(minStake <= msg.value && msg.value <= maxStake, "inv stake");
        _;
    }

    
    modifier onlyServer() {
        require(msg.sender == serverAddress);
        _;
    }

    
    modifier onlyValidTransferTimeSpan(uint transferTimeout) {
        require(transferTimeout >= MIN_TRANSFER_TIMESPAN
                && transferTimeout <= MAX_TRANSFER_TIMSPAN);
        _;
    }

    
    event LogGameCreated(address indexed user, uint indexed gameId, uint128 stake, bytes32 indexed serverEndHash, bytes32 userEndHash);

    
    event LogUserRequestedEnd(address indexed user, uint indexed gameId);

    
    event LogServerRequestedEnd(address indexed user, uint indexed gameId);

    
    event LogGameEnded(address indexed user, uint indexed gameId, uint32 roundId, int balance, ReasonEnded reason);

    
    event LogStakeLimitsModified(uint minStake, uint maxStake);

    








    constructor(
        address _serverAddress,
        uint128 _minStake,
        uint128 _maxStake,
        address _conflictResAddress,
        address _houseAddress,
        uint _chainId
    )
        public
        ConflictResolutionManager(_conflictResAddress)
    {
        require(_minStake > 0 && _minStake <= _maxStake);

        serverAddress = _serverAddress;
        houseAddress = _houseAddress;
        lastProfitTransferTimestamp = block.timestamp;
        minStake = _minStake;
        maxStake = _maxStake;

        DOMAIN_SEPERATOR =  keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH,
            keccak256("Dicether"),
            keccak256("2"),
            _chainId,
            address(this)
        ));
    }

    


    function setGameIdCntr(uint _gameIdCntr) public onlyOwner onlyNotActivated {
        require(gameIdCntr > 0);
        gameIdCntr = _gameIdCntr;
    }

    


    function withdraw() public {
        uint toTransfer = pendingReturns[msg.sender];
        require(toTransfer > 0);

        pendingReturns[msg.sender] = 0;
        msg.sender.transfer(toTransfer);
    }

    


    function transferProfitToHouse() public {
        require(lastProfitTransferTimestamp.add(profitTransferTimeSpan) <= block.timestamp);

        
        lastProfitTransferTimestamp = block.timestamp;

        if (houseProfit <= 0) {
            
            return;
        }

        uint toTransfer = houseProfit.castToUint();

        houseProfit = 0;
        houseStake = houseStake.sub(toTransfer);

        houseAddress.transfer(toTransfer);
    }

    


    function setProfitTransferTimeSpan(uint _profitTransferTimeSpan)
        public
        onlyOwner
        onlyValidTransferTimeSpan(_profitTransferTimeSpan)
    {
        profitTransferTimeSpan = _profitTransferTimeSpan;
    }

    


    function addHouseStake() public payable onlyOwner {
        houseStake = houseStake.add(msg.value);
    }

    


    function withdrawHouseStake(uint value) public onlyOwner {
        uint minHouseStake = conflictRes.minHouseStake(activeGames);

        require(value <= houseStake && houseStake.sub(value) >= minHouseStake);
        require(houseProfit <= 0 || houseProfit.castToUint() <= houseStake.sub(value));

        houseStake = houseStake.sub(value);
        owner.transfer(value);
    }

    


    function withdrawAll() public onlyOwner onlyPausedSince(3 days) {
        houseProfit = 0;
        uint toTransfer = houseStake;
        houseStake = 0;
        owner.transfer(toTransfer);
    }

    



    function setHouseAddress(address _houseAddress) public onlyOwner {
        houseAddress = _houseAddress;
    }

    




    function setStakeRequirements(uint128 _minStake, uint128 _maxStake) public onlyOwner {
        require(_minStake > 0 && _minStake <= _maxStake);
        minStake = _minStake;
        maxStake = _maxStake;
        emit LogStakeLimitsModified(minStake, maxStake);
    }

    







    function closeGame(
        Game storage _game,
        uint _gameId,
        uint32 _roundId,
        address _userAddress,
        ReasonEnded _reason,
        int _balance
    )
        internal
    {
        _game.status = GameStatus.ENDED;

        activeGames = activeGames.sub(1);

        payOut(_userAddress, _game.stake, _balance);

        emit LogGameEnded(_userAddress, _gameId, _roundId, _balance, _reason);
    }

    





    function payOut(address _userAddress, uint128 _stake, int _balance) internal {
        int stakeInt = _stake;
        int houseStakeInt = houseStake.castToInt();

        assert(_balance <= conflictRes.maxBalance());
        assert((stakeInt.add(_balance)) >= 0);

        if (_balance > 0 && houseStakeInt < _balance) {
            
            
            
            _balance = houseStakeInt;
        }

        houseProfit = houseProfit.sub(_balance);

        int newHouseStake = houseStakeInt.sub(_balance);
        houseStake = newHouseStake.castToUint();

        uint valueUser = stakeInt.add(_balance).castToUint();
        pendingReturns[_userAddress] += valueUser;
        if (pendingReturns[_userAddress] > 0) {
            safeSend(_userAddress);
        }
    }

    



    function safeSend(address _address) internal {
        uint valueToSend = pendingReturns[_address];
        assert(valueToSend > 0);

        pendingReturns[_address] = 0;
        if (_address.send(valueToSend) == false) {
            pendingReturns[_address] = valueToSend;
        }
    }

    




    function verifySig(
        uint32 _roundId,
        uint8 _gameType,
        uint _num,
        uint _value,
        int _balance,
        bytes32 _serverHash,
        bytes32 _userHash,
        uint _gameId,
        address _contractAddress,
        bytes _sig,
        address _address
    )
        internal
        view
    {
        
        address contractAddress = this;
        require(_contractAddress == contractAddress, "inv contractAddress");

        bytes32 roundHash = calcHash(
                _roundId,
                _gameType,
                _num,
                _value,
                _balance,
                _serverHash,
                _userHash,
                _gameId
        );

        verify(
                roundHash,
                _sig,
                _address
        );
    }

     





    function verify(
        bytes32 _hash,
        bytes _sig,
        address _address
    )
        internal
        pure
    {
        (bytes32 r, bytes32 s, uint8 v) = signatureSplit(_sig);
        address addressRecover = ecrecover(_hash, v, r, s);
        require(addressRecover == _address, "inv sig");
    }

    



    function calcHash(
        uint32 _roundId,
        uint8 _gameType,
        uint _num,
        uint _value,
        int _balance,
        bytes32 _serverHash,
        bytes32 _userHash,
        uint _gameId
    )
        private
        view
        returns(bytes32)
    {
        bytes32 betHash = keccak256(abi.encode(
            BET_TYPEHASH,
            _roundId,
            _gameType,
            _num,
            _value,
            _balance,
            _serverHash,
            _userHash,
            _gameId
        ));

        return keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPERATOR,
            betHash
        ));
    }

    





    function signatureSplit(bytes _signature)
        private
        pure
        returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(_signature.length == 65, "inv sig");

        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := and(mload(add(_signature, 65)), 0xff)
        }
        if (v < 2) {
            v = v + 27;
        }
    }
}
