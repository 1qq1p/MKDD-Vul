



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






contract BoostoToken is StandardToken {
    using SafeMath for uint256;

    struct HourlyReward{
        uint passedHours;
        uint percent;
    }

    string public name = "Boosto";
    string public symbol = "BST";
    uint8 public decimals = 18;

    
    uint256 public totalSupply = 1000000000 * (uint256(10) ** decimals);
    
    uint256 public totalRaised; 

    uint256 public startTimestamp; 
    
    
    uint256 public durationSeconds;

    
    uint256 public maxCap;

    
     
    uint256 public minAmount = 0.1 ether;

    
    uint256 public coinsPerETH = 1000;

    



    HourlyReward[] public hourlyRewards;

    



    bool isPublic = false;

    


    mapping(address => bool) public whiteList;
    
    



    address public fundsWallet = 0x776EFa46B4b39Aa6bd2D65ce01480B31042aeAA5;

    



    address private adminWallet = 0xc6BD816331B1BddC7C03aB51215bbb9e2BE62dD2;    
    


    constructor() public{
        

        startTimestamp = now;

        
        durationSeconds = 0;

        
        balances[fundsWallet] = totalSupply;
        Transfer(0x0, fundsWallet, totalSupply);
    }

    


    modifier isIcoOpen() {
        require(isIcoInProgress());
        _;
    }

    


    modifier checkMin(){
        require(msg.value >= minAmount);
        _;
    }

    


    modifier isWhiteListed(){
        require(isPublic || whiteList[msg.sender]);
        _;
    }

    




    modifier isAdmin(){
        require(msg.sender == fundsWallet || msg.sender == adminWallet);
        _;
    }

    



    function() public isIcoOpen checkMin isWhiteListed payable{
        totalRaised = totalRaised.add(msg.value);

        uint256 tokenAmount = calculateTokenAmount(msg.value);
        balances[fundsWallet] = balances[fundsWallet].sub(tokenAmount);
        balances[msg.sender] = balances[msg.sender].add(tokenAmount);

        Transfer(fundsWallet, msg.sender, tokenAmount);

        
        fundsWallet.transfer(msg.value);
    }

    





    function calculateTokenAmount(uint256 weiAmount) public constant returns(uint256) {
        uint256 tokenAmount = weiAmount.mul(coinsPerETH);
        
        for (uint i = 0; i < hourlyRewards.length; i++) {
            if (now <= startTimestamp + (hourlyRewards[i].passedHours * 1 hours)) {
                return tokenAmount.mul(100+hourlyRewards[i].percent).div(100);    
            }
        }
        return tokenAmount;
    }

    




    function adminUpdateWhiteList(address _address, bool _value) public isAdmin{
        whiteList[_address] = _value;
    }


    








    function adminAddICO(
        uint256 _startTimestamp,
        uint256 _durationSeconds, 
        uint256 _coinsPerETH,
        uint256 _maxCap,
        uint256 _minAmount, 
        uint[] _rewardHours,
        uint256[] _rewardPercents,
        bool _isPublic
        ) public isAdmin{

        
        assert(!isIcoInProgress());
        assert(_rewardPercents.length == _rewardHours.length);

        startTimestamp = _startTimestamp;
        durationSeconds = _durationSeconds;
        coinsPerETH = _coinsPerETH;
        maxCap = _maxCap;
        minAmount = _minAmount;

        hourlyRewards.length = 0;
        for(uint i=0; i < _rewardHours.length; i++){
            hourlyRewards[hourlyRewards.length++] = HourlyReward({
                    passedHours: _rewardHours[i],
                    percent: _rewardPercents[i]
                });
        }

        isPublic = _isPublic;
        
        totalRaised = 0;
    }

    



    function isIcoInProgress() public constant returns(bool){
        if(now < startTimestamp){
            return false;
        }
        if(now > (startTimestamp + durationSeconds)){
            return false;
        }
        if(totalRaised >= maxCap){
            return false;
        }
        return true;
    }
}