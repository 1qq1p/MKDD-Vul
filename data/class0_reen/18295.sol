pragma solidity ^0.4.18;


library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract TruSale is Ownable, Haltable {
    
    using SafeMath for uint256;
  
    TruReputationToken public truToken;

    uint256 public saleStartTime;
    
    uint256 public saleEndTime;

    uint public purchaserCount = 0;

    address public multiSigWallet;

    uint256 public constant BASE_RATE = 1000;
  
    uint256 public constant PRESALE_RATE = 1250;

    uint256 public constant SALE_RATE = 1125;

    uint256 public constant MIN_AMOUNT = 1 * 10**18;

    uint256 public constant MAX_AMOUNT = 20 * 10**18;

    uint256 public weiRaised;

    uint256 public cap;

    bool public isCompleted = false;

    bool public isPreSale = false;

    bool public isCrowdSale = false;

    uint256 public soldTokens = 0;

    mapping(address => uint256) public purchasedAmount;

    mapping(address => uint256) public tokenAmount;

    mapping (address => bool) public purchaserWhiteList;

    event TokenPurchased(
        address indexed purchaser, 
        address indexed recipient, 
        uint256 weiValue, 
        uint256 tokenAmount);

    event WhiteListUpdated(address indexed purchaserAddress, 
        bool whitelistStatus, 
        address indexed executor);

    event EndChanged(uint256 oldEnd, 
        uint256 newEnd, 
        address indexed executor);

    event Completed(address indexed executor);

    modifier onlyTokenOwner(address _tokenOwner) {
        require(msg.sender == _tokenOwner);
        _;
    }

    function TruSale(uint256 _startTime, 
        uint256 _endTime, 
        address _token, 
        address _saleWallet) public {
        require(_token != address(0));
        TruReputationToken tToken = TruReputationToken(_token);
        address tokenOwner = tToken.owner();
        createSale(_startTime, _endTime, _token, _saleWallet, tokenOwner);
    }

    function buy() public payable stopInEmergency {
        require(checkSaleValid());
        validatePurchase(msg.sender);
    }

    function updateWhitelist(address _purchaser, uint _status) public onlyOwner {
        require(_purchaser != address(0));
        bool boolStatus = false;
        if (_status == 0) {
            boolStatus = false;
        } else if (_status == 1) {
            boolStatus = true;
        } else {
            revert();
        }
        WhiteListUpdated(_purchaser, boolStatus, msg.sender);
        purchaserWhiteList[_purchaser] = boolStatus;
    }

    function changeEndTime(uint256 _endTime) public onlyOwner {
        require(_endTime >= saleStartTime);
        EndChanged(saleEndTime, _endTime, msg.sender);
        saleEndTime = _endTime;
    }

    function hasEnded() public constant returns (bool) {
        bool isCapHit = weiRaised >= cap;
        bool isExpired = now > saleEndTime;
        return isExpired || isCapHit;
    }
    
    function checkSaleValid() internal constant returns (bool) {
        bool afterStart = now >= saleStartTime;
        bool beforeEnd = now <= saleEndTime;
        bool capNotHit = weiRaised.add(msg.value) <= cap;
        return afterStart && beforeEnd && capNotHit;
    }

    function validatePurchase(address _purchaser) internal stopInEmergency {
        require(_purchaser != address(0));
        require(msg.value > 0);
        buyTokens(_purchaser);
    }

    function forwardFunds() internal {
        multiSigWallet.transfer(msg.value);
    }

    function createSale(
        uint256 _startTime, 
        uint256 _endTime, 
        address _token, 
        address _saleWallet, 
        address _tokenOwner) 
        internal onlyTokenOwner(_tokenOwner) 
    {
        require(now <= _startTime);
        require(_endTime >= _startTime);
        require(_saleWallet != address(0));
        truToken = TruReputationToken(_token);
        multiSigWallet = _saleWallet;
        saleStartTime = _startTime;
        saleEndTime = _endTime;
    }

    function buyTokens(address _purchaser) private {
        uint256 weiTotal = msg.value;
        require(weiTotal >= MIN_AMOUNT);
        if (weiTotal > MAX_AMOUNT) {
            require(purchaserWhiteList[msg.sender]); 
        }
        if (purchasedAmount[msg.sender] != 0 && !purchaserWhiteList[msg.sender]) {
            uint256 totalPurchased = purchasedAmount[msg.sender];
            totalPurchased = totalPurchased.add(weiTotal);
            require(totalPurchased < MAX_AMOUNT);
        }
        uint256 tokenRate = BASE_RATE;    
        if (isPreSale) {
            tokenRate = PRESALE_RATE;
        }
        if (isCrowdSale) {
            tokenRate = SALE_RATE;
        }
        uint256 noOfTokens = weiTotal.mul(tokenRate);
        weiRaised = weiRaised.add(weiTotal);
        if (purchasedAmount[msg.sender] == 0) {
            purchaserCount++;
        }
        soldTokens = soldTokens.add(noOfTokens);
        purchasedAmount[msg.sender] = purchasedAmount[msg.sender].add(msg.value);
        tokenAmount[msg.sender] = tokenAmount[msg.sender].add(noOfTokens);
        truToken.mint(_purchaser, noOfTokens);
        TokenPurchased(msg.sender,
        _purchaser,
        weiTotal,
        noOfTokens);
        forwardFunds();
    }
}

