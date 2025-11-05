pragma solidity ^0.4.18;














contract krypteum is ERC20Coin {

  

  string public constant name = "krypteum";
  string public constant symbol = "KTM";
  uint8  public constant decimals = 2;

  

  address public wallet;
  address public administrator;

  

  uint public constant DATE_ICO_START = 1518480000; 
  uint public constant DATE_ICO_END   = 1522713540; 

  
  uint public constant COIN_COST_ICO_TIER_1 = 110 finney; 
  uint public constant COIN_COST_ICO_TIER_2 = 120 finney; 
  uint public constant COIN_COST_ICO_TIER_3 = 130 finney; 

  

  uint public constant COIN_SUPPLY_ICO_TIER_1 = 50000; 
  uint public constant COIN_SUPPLY_ICO_TIER_2 = 25000; 
  uint public constant COIN_SUPPLY_ICO_TIER_3 = 25000; 
  uint public constant COIN_SUPPLY_ICO_TOTAL =         
    COIN_SUPPLY_ICO_TIER_1 + COIN_SUPPLY_ICO_TIER_2 + COIN_SUPPLY_ICO_TIER_3;

  uint public constant COIN_SUPPLY_MARKETING_TOTAL =   200000; 

  

  uint public constant COOLDOWN_PERIOD =  24 hours;

  

  uint public icoEtherReceived = 0; 
  uint public coinsIssuedMkt = 0;
  uint public coinsIssuedIco  = 0;
  uint[] public numberOfCoinsAvailableInIcoTier;
  uint[] public costOfACoinInWeiForTier;

  

  mapping(address => uint) public icoEtherContributed;
  mapping(address => uint) public icoCoinsReceived;

  

  

  mapping(address => bool) public locked;

  

  event WalletUpdated(address _newWallet);
  event AdministratorUpdated(address _newAdministrator);
  event CoinsMinted(address indexed _owner, uint _coins, uint _balance);
  event CoinsIssued(address indexed _owner, uint _coins, uint _balance, uint _etherContributed);
  event LockRemoved(address indexed _participant);

  

  

  function krypteum() public {
    wallet = owner;
    administrator = owner;

    numberOfCoinsAvailableInIcoTier.length = 3;
    numberOfCoinsAvailableInIcoTier[0] = COIN_SUPPLY_ICO_TIER_1;
    numberOfCoinsAvailableInIcoTier[1] = COIN_SUPPLY_ICO_TIER_2;
    numberOfCoinsAvailableInIcoTier[2] = COIN_SUPPLY_ICO_TIER_3;

    costOfACoinInWeiForTier.length = 3;
    costOfACoinInWeiForTier[0] = COIN_COST_ICO_TIER_1;
    costOfACoinInWeiForTier[1] = COIN_COST_ICO_TIER_2;
    costOfACoinInWeiForTier[2] = COIN_COST_ICO_TIER_3;
  }

  

  function () public payable {
    buyCoins();
  }

  

  

  function atNow() public constant returns (uint) {
    return now;
  }

    

  function isTransferable() public constant returns (bool transferable) {
      return atNow() >= DATE_ICO_END + COOLDOWN_PERIOD;
  }

  

  

  function removeLock(address _participant) public {
    require(msg.sender == administrator || msg.sender == owner);

    locked[_participant] = false;
    LockRemoved(_participant);
  }

  function removeLockMultiple(address[] _participants) public {
    require(msg.sender == administrator || msg.sender == owner);

    for (uint i = 0; i < _participants.length; i++) {
      locked[_participants[i]] = false;
      LockRemoved(_participants[i]);
    }
  }

  

  

  function setWallet(address _wallet) public onlyOwner {
    require(_wallet != address(0x0));
    wallet = _wallet;
    WalletUpdated(wallet);
  }

  

  function setAdministrator(address _admin) public onlyOwner {
    require(_admin != address(0x0));
    administrator = _admin;
    AdministratorUpdated(administrator);
  }

  

  function grantCoins(address _participant, uint _coins) public onlyOwner {
    
    require(_coins <= COIN_SUPPLY_MARKETING_TOTAL.sub(coinsIssuedMkt));

    
    balances[_participant] = balances[_participant].add(_coins);
    coinsIssuedMkt = coinsIssuedMkt.add(_coins);
    coinsIssuedTotal = coinsIssuedTotal.add(_coins);

    
    locked[_participant] = true;

    
    Transfer(0x0, _participant, _coins);
    CoinsMinted(_participant, _coins, balances[_participant]);
  }

  

  function transferAnyERC20Token(address tokenAddress, uint amount) public onlyOwner returns (bool success) {
      return ERC20Interface(tokenAddress).transfer(owner, amount);
  }

  

  

  function buyCoins() private {
    uint ts = atNow();
    uint coins = 0;
    uint change = 0;

    
    require(DATE_ICO_START < ts && ts < DATE_ICO_END);

    (coins, change) = calculateCoinsPerWeiAndUpdateAvailableIcoCoins(msg.value);

    
    require(coins > 0);

    
    require(coinsIssuedIco.add(coins).add(sumOfAvailableIcoCoins()) == COIN_SUPPLY_ICO_TOTAL);

    
    require(change == 0 || coinsIssuedIco.add(coins) == COIN_SUPPLY_ICO_TOTAL);

    
    balances[msg.sender] = balances[msg.sender].add(coins);
    icoCoinsReceived[msg.sender] = icoCoinsReceived[msg.sender].add(coins);
    coinsIssuedIco = coinsIssuedIco.add(coins);
    coinsIssuedTotal = coinsIssuedTotal.add(coins);

    
    icoEtherReceived = icoEtherReceived.add(msg.value).sub(change);
    icoEtherContributed[msg.sender] = icoEtherContributed[msg.sender].add(msg.value).sub(change);

    
    locked[msg.sender] = true;

    
    Transfer(0x0, msg.sender, coins);
    CoinsIssued(msg.sender, coins, balances[msg.sender], msg.value.sub(change));

    
    if (change > 0)
       msg.sender.transfer(change);

    wallet.transfer(this.balance);
  }

  function sumOfAvailableIcoCoins() internal constant returns (uint totalAvailableIcoCoins) {
    totalAvailableIcoCoins = 0;
    for (uint8 i = 0; i < numberOfCoinsAvailableInIcoTier.length; i++) {
      totalAvailableIcoCoins = totalAvailableIcoCoins.add(numberOfCoinsAvailableInIcoTier[i]);
    }
  }

  function calculateCoinsPerWeiAndUpdateAvailableIcoCoins(uint value) internal returns (uint coins, uint change) {
    coins = 0;
    change = value;

    for (uint8 i = 0; i < numberOfCoinsAvailableInIcoTier.length; i++) {
      uint costOfAvailableCoinsInCurrentTier = numberOfCoinsAvailableInIcoTier[i].mul(costOfACoinInWeiForTier[i]);

      if (change <= costOfAvailableCoinsInCurrentTier) {
        uint coinsInCurrentTierToBuy = change.div(costOfACoinInWeiForTier[i]);
        coins = coins.add(coinsInCurrentTierToBuy);
        numberOfCoinsAvailableInIcoTier[i] = numberOfCoinsAvailableInIcoTier[i].sub(coinsInCurrentTierToBuy);
        change = 0;
        break;
      }

      coins = coins.add(numberOfCoinsAvailableInIcoTier[i]);
      change = change.sub(costOfAvailableCoinsInCurrentTier);
      numberOfCoinsAvailableInIcoTier[i] = 0;
    }
  }

  

  

  function transfer(address _to, uint _amount) public returns (bool success) {
    require(isTransferable());
    require(locked[msg.sender] == false);
    require(locked[_to] == false);

    return super.transfer(_to, _amount);
  }

  

  function transferFrom(address _from, address _to, uint _amount) public returns (bool success) {
    require(isTransferable());
    require(locked[_from] == false);
    require(locked[_to] == false);

    return super.transferFrom(_from, _to, _amount);
  }

  

  
  

  function transferMultiple(address[] _addresses, uint[] _amounts) external {
    require(isTransferable());
    require(locked[msg.sender] == false);
    require(_addresses.length == _amounts.length);

    for (uint i = 0; i < _addresses.length; i++) {
      if (locked[_addresses[i]] == false)
         super.transfer(_addresses[i], _amounts[i]);
    }
  }
}