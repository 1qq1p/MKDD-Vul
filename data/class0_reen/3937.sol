pragma solidity ^0.4.24;









library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  


  function add(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = true;
  }

  


  function remove(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = false;
  }

  



  function check(Role storage _role, address _addr)
    internal
    view
  {
    require(has(_role, _addr));
  }

  



  function has(Role storage _role, address _addr)
    internal
    view
    returns (bool)
  {
    return _role.bearer[_addr];
  }
}












contract FUTM1 is MintableToken, BurnableToken, RBAC {
  using SafeMath for uint256;

  string public constant name = "Futereum Markets 1";
  string public constant symbol = "FUTM1";
  uint8 public constant decimals = 18;

  string public constant ROLE_ADMIN = "admin";
  string public constant ROLE_SUPER = "super";

  uint public swapLimit;
  uint public constant CYCLE_CAP = 100000 * (10 ** uint256(decimals));
  uint public constant BILLION = 10 ** 9;

  event SwapStarted(uint256 startTime);
  event MiningRestart(uint256 endTime);
  event CMCUpdate(string updateType, uint value);

  uint offset = 10**18;
  
  uint public exchangeRateFUTB;

  
  uint public cycleMintSupply = 0;
  bool public isMiningOpen = false;
  uint public CMC = 129238998229;
  uint public cycleEndTime;

  address public constant FUTC = 0xf880d3C6DCDA42A7b2F6640703C5748557865B35;
  address public constant FUTB = 0x30c6Fe3AC0260A855c90caB79AA33e76091d4904;

  constructor() public {
    
    owner = this;
    totalSupply_ = 0;
    addRole(msg.sender, ROLE_ADMIN);
    addRole(msg.sender, ROLE_SUPER);

    
    exchangeRateFUTB = offset.mul(offset).div(CMC.mul(offset).div(BILLION)).mul(65).div(100);
    cycleEndTime = now + 100 days;
  }

  modifier canMine() {
    require(isMiningOpen);
    _;
  }

  
  function mine(uint amount) canMine external {
    require(amount > 0);
    require(cycleMintSupply < CYCLE_CAP);
    require(ERC20(FUTB).transferFrom(msg.sender, address(this), amount));

    uint refund = _mine(exchangeRateFUTB, amount);
    if(refund > 0) {
      ERC20(FUTB).transfer(msg.sender, refund);
    }
    if (cycleMintSupply >= CYCLE_CAP || now > cycleEndTime) {
      
      _startSwap();
    }
  }

  function _mine(uint _rate, uint _inAmount) private returns (uint) {
    assert(_rate > 0);

    
    if (now > cycleEndTime && cycleMintSupply > 0) {
      return _inAmount;
    }
    uint tokens = _rate.mul(_inAmount).div(offset);
    uint refund = 0;

    
    uint futcFeed = tokens.mul(35).div(65);

    if (tokens + futcFeed + cycleMintSupply > CYCLE_CAP) {
      uint overage = tokens + futcFeed + cycleMintSupply - CYCLE_CAP;
      uint tokenOverage = overage.mul(65).div(100);
      futcFeed -= (overage - tokenOverage);
      tokens -= tokenOverage;

      
      refund = tokenOverage.mul(offset).div(_rate);
    }
    cycleMintSupply += (tokens + futcFeed);
    require(futcFeed > 0, "Mining payment too small.");
    MintableToken(this).mint(msg.sender, tokens);
    MintableToken(this).mint(FUTC, futcFeed);

    return refund;
  }

  
  bool public swapOpen = false;
  mapping(address => uint) public swapRates;

  function _startSwap() private {
    swapOpen = true;
    isMiningOpen = false;

    
    
    swapLimit = cycleMintSupply.mul(35).div(100);
    swapRates[FUTB] = ERC20(FUTB).balanceOf(address(this)).mul(offset).mul(35).div(100).div(swapLimit);

    emit SwapStarted(now);
  }

  function swap(uint amt) public {
    require(swapOpen && swapLimit > 0);
    if (amt > swapLimit) {
      amt = swapLimit;
    }
    swapLimit -= amt;
    
    burn(amt);

    if (amt.mul(swapRates[FUTB]) > 0) {
      ERC20(FUTB).transfer(msg.sender, amt.mul(swapRates[FUTB]).div(offset));
    }

    if (swapLimit == 0) {
      _restart();
    }
  }

  function _restart() private {
    require(swapOpen);
    require(swapLimit == 0);

    cycleMintSupply = 0;
    swapOpen = false;
    isMiningOpen = true;
    cycleEndTime = now + 100 days;

    emit MiningRestart(cycleEndTime);
  }

  function updateCMC(uint _cmc) public onlyAdmin {
    require(_cmc > 0);
    CMC = _cmc;
    emit CMCUpdate("TOTAL_CMC", _cmc);
    exchangeRateFUTB = offset.mul(offset).div(CMC.mul(offset).div(BILLION)).mul(65).div(100);
  }

  function setIsMiningOpen(bool isOpen) onlyAdmin external {
    isMiningOpen = isOpen;
  }

  modifier onlySuper() {
    checkRole(msg.sender, ROLE_SUPER);
    _;
  }

  modifier onlyAdmin() {
    checkRole(msg.sender, ROLE_ADMIN);
    _;
  }

  function addAdmin(address _addr) public onlySuper {
    addRole(_addr, ROLE_ADMIN);
  }

  function removeAdmin(address _addr) public onlySuper {
    removeRole(_addr, ROLE_ADMIN);
  }

  function changeSuper(address _addr) public onlySuper {
    addRole(_addr, ROLE_SUPER);
    removeRole(msg.sender, ROLE_SUPER);
  }
}