pragma solidity ^0.4.18;





contract PreFund is Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) public deposited;
  mapping (address => uint256) public claimed;

  
  ElementhToken public token;

  
  uint256 public startTime;
  uint256 public endTime;

  
  address public wallet;


  
  uint256 public rate;

  event Refunded(address indexed beneficiary, uint256 weiAmount);
  event AddDeposit(address indexed beneficiary, uint256 value);
  event LogClaim(address indexed holder, uint256 amount);

  function setStartTime(uint256 _startTime) public onlyOwner{
    startTime = _startTime;
  }

  function setEndTime(uint256 _endTime) public onlyOwner{
    endTime = _endTime;
  }

  function setWallet(address _wallet) public onlyOwner{
    wallet = _wallet;
  }

  function setRate(uint256 _rate) public onlyOwner{
    rate = _rate;
  }


  function PreFund(uint256 _startTime, uint256 _endTime, address _wallet, ElementhToken _token) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_wallet != address(0));
    require(_token != address(0));

    token = _token;
    startTime = _startTime;
    endTime = _endTime;
    wallet = _wallet;
  }

  function () external payable {
    deposit(msg.sender);
  }

  
  function deposit(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    deposited[beneficiary] = deposited[beneficiary].add(msg.value);

    uint256 weiAmount = msg.value;
    AddDeposit(beneficiary, weiAmount);
  }

  
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }


  
  function forwardFunds() onlyOwner public {
    require(now >= endTime);
    wallet.transfer(this.balance);
  }

  function claimToken () public {
    require (msg.sender != address(0));
    require (now >= endTime);
    require (deposited[msg.sender] != 0);
    
    uint tokens = deposited[msg.sender] * rate;

    token.mint(msg.sender, tokens);
    deposited[msg.sender] = 0;
    claimed[msg.sender] = tokens;

    LogClaim(msg.sender, tokens);
  }
  

  function refundWallet(address _wallet) onlyOwner public {
    refundFunds(_wallet);
  }

  function claimRefund() public {
  	require(now <= endTime);
    refundFunds(msg.sender);
  }

  function refundFunds(address _wallet) internal {
    require(_wallet != address(0));
    require(deposited[_wallet] != 0);
    uint256 depositedValue = deposited[_wallet];
    deposited[_wallet] = 0;
    _wallet.transfer(depositedValue);
    if(claimed[_wallet] != 0){
    	token.burn(_wallet, claimed[_wallet]);
    	claimed[_wallet] = 0;
    }
    Refunded(_wallet, depositedValue);
  }

}