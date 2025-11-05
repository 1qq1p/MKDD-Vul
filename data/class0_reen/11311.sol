pragma solidity ^0.4.23;







library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    
    
    
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}








contract ZeexCrowdsale is CappedCrowdsale, MintedCrowdsale, TimedCrowdsale, Pausable, ZeexWhitelistedCrowdsale {
  using SafeMath for uint256;

  uint256 public presaleOpeningTime;
  uint256 public presaleClosingTime;
  uint256 public presaleBonus = 25;
  uint256 public minPresaleWei;
  uint256 public maxPresaleWei;

  bytes1 public constant publicPresale = "0";
  bytes1 public constant privatePresale = "1";

  address[] public bonusUsers;
  mapping(address => mapping(bytes1 => uint256)) public bonusTokens;

  event Lock(address user, uint amount, bytes1 tokenType);
  event ReleaseLockedTokens(bytes1 tokenType, address user, uint amount, address to);

  constructor(uint256 _openingTime, uint256 _closingTime, uint hardCapWei,
    uint256 _presaleOpeningTime, uint256 _presaleClosingTime,
    uint256 _minPresaleWei, uint256 _maxPresaleWei,
    address _wallet, MintableToken _token, address _whitelister) public
    Crowdsale(5000, _wallet, _token)
    CappedCrowdsale(hardCapWei)
    TimedCrowdsale(_openingTime, _closingTime)
    validPresaleClosingTime(_presaleOpeningTime, _presaleClosingTime)
    ZeexWhitelistedCrowdsale(_whitelister) {

    require(_presaleOpeningTime >= openingTime);
    require(_maxPresaleWei >= _minPresaleWei);

    presaleOpeningTime = _presaleOpeningTime;
    presaleClosingTime = _presaleClosingTime;
    minPresaleWei = _minPresaleWei;
    maxPresaleWei = _maxPresaleWei;

    paused = true;
  }

  
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenNotPaused {
    super._preValidatePurchase(_beneficiary, _weiAmount);

    if (isPresaleOn()) {
      require(_weiAmount >= minPresaleWei && _weiAmount <= maxPresaleWei);
    }
  }

  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    return _weiAmount.mul(rate).add(getPresaleBonusAmount(_weiAmount));
  }

  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
    uint256 weiAmount = msg.value;
    uint256 lockedAmount = getPresaleBonusAmount(weiAmount);
    uint256 unlockedAmount = _tokenAmount.sub(lockedAmount);

    if (lockedAmount > 0) {
      lockAndDeliverTokens(_beneficiary, lockedAmount, publicPresale);
    }

    _deliverTokens(_beneficiary, unlockedAmount);
  }
  

  function grantTokens(address _beneficiary, uint256 _tokenAmount) public onlyOwner {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  function grantBonusTokens(address _beneficiary, uint256 _tokenAmount) public onlyOwner {
    lockAndDeliverTokens(_beneficiary, _tokenAmount, privatePresale);
  }

  

  function lockAndDeliverTokens(address _beneficiary, uint256 _tokenAmount, bytes1 _type) internal {
    lockBonusTokens(_beneficiary, _tokenAmount, _type);
    _deliverTokens(address(this), _tokenAmount);
  }

  function lockBonusTokens(address _beneficiary, uint256 _amount, bytes1 _type) internal {
    if (bonusTokens[_beneficiary][publicPresale] == 0 && bonusTokens[_beneficiary][privatePresale] == 0) {
      bonusUsers.push(_beneficiary);
    }

    bonusTokens[_beneficiary][_type] = bonusTokens[_beneficiary][_type].add(_amount);
    emit Lock(_beneficiary, _amount, _type);
  }

  function getBonusBalance(uint _from, uint _to) public view returns (uint total) {
    require(_from >= 0 && _to >= _from && _to <= bonusUsers.length);

    for (uint i = _from; i < _to; i++) {
      total = total.add(getUserBonusBalance(bonusUsers[i]));
    }
  }

  function getBonusBalanceByType(uint _from, uint _to, bytes1 _type) public view returns (uint total) {
    require(_from >= 0 && _to >= _from && _to <= bonusUsers.length);

    for (uint i = _from; i < _to; i++) {
      total = total.add(bonusTokens[bonusUsers[i]][_type]);
    }
  }

  function getUserBonusBalanceByType(address _user, bytes1 _type) public view returns (uint total) {
    return bonusTokens[_user][_type];
  }

  function getUserBonusBalance(address _user) public view returns (uint total) {
    total = total.add(getUserBonusBalanceByType(_user, publicPresale));
    total = total.add(getUserBonusBalanceByType(_user, privatePresale));
  }

  function getBonusUsersCount() public view returns(uint count) {
    return bonusUsers.length;
  }

  function releasePublicPresaleBonusTokens(address[] _users, uint _percentage) public onlyOwner {
    require(_percentage > 0 && _percentage <= 100);

    for (uint i = 0; i < _users.length; i++) {
      address user = _users[i];
      uint tokenBalance = bonusTokens[user][publicPresale];
      uint amount = tokenBalance.mul(_percentage).div(100);
      releaseBonusTokens(user, amount, user, publicPresale);
    }
  }

  function releaseUserPrivateBonusTokens(address _user, uint _amount, address _to) public onlyOwner {
    releaseBonusTokens(_user, _amount, _to, privatePresale);
  }

  function releasePrivateBonusTokens(address[] _users, uint[] _amounts) public onlyOwner {
    for (uint i = 0; i < _users.length; i++) {
      address user = _users[i];
      uint amount = _amounts[i];
      releaseBonusTokens(user, amount, user, privatePresale);
    }
  }

  function releaseBonusTokens(address _user, uint _amount, address _to, bytes1 _type) internal onlyOwner {
    uint tokenBalance = bonusTokens[_user][_type];
    require(tokenBalance >= _amount);

    bonusTokens[_user][_type] = bonusTokens[_user][_type].sub(_amount);
    token.transfer(_to, _amount);
    emit ReleaseLockedTokens(_type, _user, _amount, _to);
  }

  
  function getPresaleBonusAmount(uint256 _weiAmount) internal view returns (uint256) {
    uint256 tokenAmount = 0;
    if (isPresaleOn()) tokenAmount = (_weiAmount.mul(presaleBonus).div(100)).mul(rate);

    return tokenAmount;
  }

  function updatePresaleMinWei(uint _minPresaleWei) public onlyOwner {
    require(maxPresaleWei >= _minPresaleWei);

    minPresaleWei = _minPresaleWei;
  }

  function updatePresaleMaxWei(uint _maxPresaleWei) public onlyOwner {
    require(_maxPresaleWei >= minPresaleWei);

    maxPresaleWei = _maxPresaleWei;
  }

  function updatePresaleBonus(uint _presaleBonus) public onlyOwner {
    presaleBonus = _presaleBonus;
  }

  function isPresaleOn() public view returns (bool) {
    return block.timestamp >= presaleOpeningTime && block.timestamp <= presaleClosingTime;
  }

  modifier validPresaleClosingTime(uint _presaleOpeningTime, uint _presaleClosingTime) {
    require(_presaleOpeningTime >= openingTime);
    require(_presaleClosingTime >= _presaleOpeningTime);
    require(_presaleClosingTime <= closingTime);
    _;
  }

  function setOpeningTime(uint256 _openingTime) public onlyOwner {
    require(_openingTime >= block.timestamp);
    require(presaleOpeningTime >= _openingTime);
    require(closingTime >= _openingTime);

    openingTime = _openingTime;
  }

  function setPresaleClosingTime(uint _presaleClosingTime) public onlyOwner validPresaleClosingTime(presaleOpeningTime, _presaleClosingTime) {
    presaleClosingTime = _presaleClosingTime;
  }

  function setPresaleOpeningClosingTime(uint256 _presaleOpeningTime, uint256 _presaleClosingTime) public onlyOwner validPresaleClosingTime(_presaleOpeningTime, _presaleClosingTime) {
    presaleOpeningTime = _presaleOpeningTime;
    presaleClosingTime = _presaleClosingTime;
  }

  function setClosingTime(uint256 _closingTime) public onlyOwner {
    require(_closingTime >= block.timestamp);
    require(_closingTime >= openingTime);

    closingTime = _closingTime;
  }

  function setOpeningClosingTime(uint256 _openingTime, uint256 _closingTime) public onlyOwner {
    require(_openingTime >= block.timestamp);
    require(_closingTime >= _openingTime);

    openingTime = _openingTime;
    closingTime = _closingTime;
  }

  function transferTokenOwnership(address _to) public onlyOwner {
    Ownable(token).transferOwnership(_to);
  }
}