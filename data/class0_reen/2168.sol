pragma solidity ^0.4.15;






contract SpectreSubscriberToken is StandardToken, Pausable, TokenController {
  using SafeMath for uint;

  string public constant name = "SPECTRE SUBSCRIBER TOKEN";
  string public constant symbol = "SXS";
  uint256 public constant decimals = 18;

  uint256 constant public TOKENS_AVAILABLE             = 240000000 * 10**decimals;
  uint256 constant public BONUS_SLAB                   = 100000000 * 10**decimals;
  uint256 constant public MIN_CAP                      = 5000000 * 10**decimals;
  uint256 constant public MIN_FUND_AMOUNT              = 1 ether;
  uint256 constant public TOKEN_PRICE                  = 0.0005 ether;
  uint256 constant public WHITELIST_PERIOD             = 3 days;

  address public specWallet;
  address public specDWallet;
  address public specUWallet;

  bool public refundable = false;
  bool public configured = false;
  bool public tokenAddressesSet = false;
  
  uint256 public presaleStart;
  uint256 public presaleEnd;
  
  uint256 public saleStart;
  uint256 public saleEnd;
  
  uint256 public discountSaleEnd;

  
  mapping(address => uint256) public whitelist;
  uint256 constant D160 = 0x0010000000000000000000000000000000000000000;

  
  mapping(address => uint256) public bonus;

  event Refund(address indexed _to, uint256 _value);
  event ContractFunded(address indexed _from, uint256 _value, uint256 _total);
  event Refundable();
  event WhiteListSet(address indexed _subscriber, uint256 _value);
  event OwnerTransfer(address indexed _from, address indexed _to, uint256 _value);

  modifier isRefundable() {
    require(refundable);
    _;
  }

  modifier isNotRefundable() {
    require(!refundable);
    _;
  }

  modifier isTransferable() {
    require(tokenAddressesSet);
    require(getNow() > saleEnd);
    require(totalSupply >= MIN_CAP);
    _;
  }

  modifier onlyWalletOrOwner() {
    require(msg.sender == owner || msg.sender == specWallet);
    _;
  }

  
  
  
  
  function SpectreSubscriberToken(address _specWallet) {
    require(_specWallet != address(0));
    specWallet = _specWallet;
    pause();
  }

  
  
  function() payable whenNotPaused public {
    require(msg.value >= MIN_FUND_AMOUNT);
    if(getNow() >= presaleStart && getNow() <= presaleEnd) {
      purchasePresale();
    } else if (getNow() >= saleStart && getNow() <= saleEnd) {
      purchase();
    } else {
      revert();
    }
  }

  
  function purchasePresale() internal {
    
    if (getNow() < (presaleStart + WHITELIST_PERIOD)) {
      require(whitelist[msg.sender] > 0);
      
      uint256 minAllowed = whitelist[msg.sender].mul(95).div(100);
      uint256 maxAllowed = whitelist[msg.sender].mul(120).div(100);
      require(msg.value >= minAllowed && msg.value <= maxAllowed);
      
      whitelist[msg.sender] = 0;
    }

    uint256 numTokens = msg.value.mul(10**decimals).div(TOKEN_PRICE);
    uint256 bonusTokens = 0;

    if(totalSupply < BONUS_SLAB) {
      
      uint256 remainingBonusSlabTokens = SafeMath.sub(BONUS_SLAB, totalSupply);
      uint256 bonusSlabTokens = Math.min256(remainingBonusSlabTokens, numTokens);
      uint256 nonBonusSlabTokens = SafeMath.sub(numTokens, bonusSlabTokens);
      bonusTokens = bonusSlabTokens.mul(33).div(100);
      bonusTokens = bonusTokens.add(nonBonusSlabTokens.mul(22).div(100));
    } else {
      
      bonusTokens = numTokens.mul(22).div(100);
    }
    
    numTokens = numTokens.add(bonusTokens);
    bonus[msg.sender] = bonus[msg.sender].add(bonusTokens);

    
    specWallet.transfer(msg.value);

    totalSupply = totalSupply.add(numTokens);
    require(totalSupply <= TOKENS_AVAILABLE);

    balances[msg.sender] = balances[msg.sender].add(numTokens);
    
    Transfer(0, msg.sender, numTokens);

  }

  
  function purchase() internal {

    uint256 numTokens = msg.value.mul(10**decimals).div(TOKEN_PRICE);
    uint256 bonusTokens = 0;

    if(getNow() <= discountSaleEnd) {
      
      bonusTokens = numTokens.mul(11).div(100);
    }

    numTokens = numTokens.add(bonusTokens);
    bonus[msg.sender] = bonus[msg.sender].add(bonusTokens);

    
    specWallet.transfer(msg.value);

    totalSupply = totalSupply.add(numTokens);

    require(totalSupply <= TOKENS_AVAILABLE);
    balances[msg.sender] = balances[msg.sender].add(numTokens);
    
    Transfer(0, msg.sender, numTokens);
  }

  
  function numberOfTokensLeft() constant returns (uint256) {
    return TOKENS_AVAILABLE.sub(totalSupply);
  }

  
  function unpause() onlyOwner whenPaused public {
    require(configured);
    paused = false;
    Unpause();
  }

  
  
  
  function setTokenAddresses(address _specUWallet, address _specDWallet) onlyOwner public {
    require(!tokenAddressesSet);
    require(_specDWallet != address(0));
    require(_specUWallet != address(0));
    require(isContract(_specDWallet));
    require(isContract(_specUWallet));
    specUWallet = _specUWallet;
    specDWallet = _specDWallet;
    tokenAddressesSet = true;
    if (configured) {
      unpause();
    }
  }

  
  
  
  
  
  
  
  function configure(uint256 _presaleStart, uint256 _presaleEnd, uint256 _saleStart, uint256 _saleEnd, uint256 _discountSaleEnd) onlyOwner public {
    require(!configured);
    require(_presaleStart > getNow());
    require(_presaleEnd > _presaleStart);
    require(_saleStart > _presaleEnd);
    require(_saleEnd > _saleStart);
    require(_discountSaleEnd > _saleStart && _discountSaleEnd <= _saleEnd);
    presaleStart = _presaleStart;
    presaleEnd = _presaleEnd;
    saleStart = _saleStart;
    saleEnd = _saleEnd;
    discountSaleEnd = _discountSaleEnd;
    configured = true;
    if (tokenAddressesSet) {
      unpause();
    }
  }

  
  
  function refund() isRefundable public {
    require(balances[msg.sender] > 0);

    uint256 tokenValue = balances[msg.sender].sub(bonus[msg.sender]);
    balances[msg.sender] = 0;
    tokenValue = tokenValue.mul(TOKEN_PRICE).div(10**decimals);

    
    msg.sender.transfer(tokenValue);
    Refund(msg.sender, tokenValue);
  }

  function withdrawEther() public isNotRefundable onlyOwner {
    
    msg.sender.transfer(this.balance);
  }

  
  
  function fundContract() public payable onlyWalletOrOwner {
    
    ContractFunded(msg.sender, msg.value, this.balance);
  }

  function setRefundable() onlyOwner {
    require(this.balance > 0);
    require(getNow() > saleEnd);
    require(totalSupply < MIN_CAP);
    Refundable();
    refundable = true;
  }

  
  
  function transfer(address _to, uint256 _value) isTransferable returns (bool success) {
    
    
    require(_to == specDWallet || _to == specUWallet);
    require(isContract(_to));
    bytes memory empty;
    return transferToContract(msg.sender, _to, _value, empty);
  }

  
  function isContract(address _addr) private returns (bool is_contract) {
    uint256 length;
    assembly {
      
      length := extcodesize(_addr)
    }
    return (length>0);
  }

  
  function transferToContract(address _from, address _to, uint256 _value, bytes _data) internal returns (bool success) {
    require(balanceOf(_from) >= _value);
    balances[_from] = balanceOf(_from).sub(_value);
    balances[_to] = balanceOf(_to).add(_value);
    ContractReceiver receiver = ContractReceiver(_to);
    receiver.tokenFallback(_from, _value, _data);
    Transfer(_from, _to, _value);
    return true;
  }

  





  function transferFrom(address _from, address _to, uint256 _value) public isTransferable returns (bool) {
    require(_to == specDWallet || _to == specUWallet);
    require(isContract(_to));
    
    if (msg.sender == owner && getNow() > saleEnd + 28 days) {
      OwnerTransfer(_from, _to, _value);
    } else {
      uint256 _allowance = allowed[_from][msg.sender];
      allowed[_from][msg.sender] = _allowance.sub(_value);
    }

    
    bytes memory empty;
    return transferToContract(_from, _to, _value, empty);

  }

  
  function setWhiteList(address _subscriber, uint256 _amount) public onlyOwner {
    require(_subscriber != address(0));
    require(_amount != 0);
    whitelist[_subscriber] = _amount;
    WhiteListSet(_subscriber, _amount);
  }

  
  
  
  function multiSetWhiteList(uint256[] data) public onlyOwner {
    for (uint256 i = 0; i < data.length; i++) {
      address addr = address(data[i] & (D160 - 1));
      uint256 amount = data[i] / D160;
      setWhiteList(addr, amount);
    }
  }

  
  
  

  
  
  

  function proxyPayment(address _owner) payable returns(bool) {
      return false;
  }

  
  
  
  
  
  
  function onTransfer(address _from, address _to, uint _amount) returns(bool) {
      return true;
  }

  
  
  
  
  
  
  function onApprove(address _owner, address _spender, uint _amount)
      returns(bool)
  {
      return true;
  }

  function getNow() constant internal returns (uint256) {
    return now;
  }

}