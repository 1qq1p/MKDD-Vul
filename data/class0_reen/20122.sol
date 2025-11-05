pragma solidity ^0.4.23;







contract HEXCrowdSale is Ownerable, SafeMath, ATXICOToken {
  uint256 public maxHEXCap;
  uint256 public minHEXCap;

  uint256 public ethRate;
  uint256 public atxRate;
  


  address[] public ethInvestors;
  mapping (address => uint256) public ethInvestorFunds;

  address[] public atxInvestors;
  mapping (address => uint256) public atxInvestorFunds;

  address[] public atxChangeAddrs;
  mapping (address => uint256) public atxChanges;

  KYC public kyc;
  HEX public hexToken;
  address public hexControllerAddr;
  ERC20Basic public atxToken;
  address public atxControllerAddr;
  

  address[] public memWallets;
  address[] public vaultWallets;

  struct Period {
    uint256 startTime;
    uint256 endTime;
    uint256 bonus; 
  }
  Period[] public periods;

  bool public isInitialized;
  bool public isFinalized;

  function init (
    address _kyc,
    address _token,
    address _hexController,
    address _atxToken,
    address _atxController,
    
    address[] _memWallets,
    address[] _vaultWallets,
    uint256 _ethRate,
    uint256 _atxRate,
    uint256 _maxHEXCap,
    uint256 _minHEXCap ) public onlyOwner {

      require(isInitialized == false);

      kyc = KYC(_kyc);
      hexToken = HEX(_token);
      hexControllerAddr = _hexController;
      atxToken = ERC20Basic(_atxToken);
      atxControllerAddr = _atxController;

      memWallets = _memWallets;
      vaultWallets = _vaultWallets;

      


      ethRate = _ethRate;
      atxRate = _atxRate;

      maxHEXCap = _maxHEXCap;
      minHEXCap = _minHEXCap;

      isInitialized = true;
    }

    function () public payable {
      ethBuy();
    }

    function ethBuy() internal {
      
      require(msg.value >= 50e18); 

      require(isInitialized);
      require(!isFinalized);

      require(msg.sender != 0x0 && msg.value != 0x0);
      require(kyc.registeredAddress(msg.sender));
      require(maxReached() == false);
      require(onSale());

      uint256 fundingAmt = msg.value;
      uint256 bonus = getPeriodBonus();
      uint256 currTotalSupply = hexToken.totalSupply();
      uint256 fundableHEXRoom = sub(maxHEXCap, currTotalSupply);
      uint256 reqedHex = eth2HexWithBonus(fundingAmt, bonus);
      uint256 toFund;
      uint256 reFund;

      if(reqedHex > fundableHEXRoom) {
        reqedHex = fundableHEXRoom;

        toFund = hex2EthWithBonus(reqedHex, bonus); 
        reFund = sub(fundingAmt, toFund);

        
        
        

      } else {
        toFund = fundingAmt;
        reFund = 0;
      }

      require(fundingAmt >= toFund);
      require(toFund > 0);

      
      if(ethInvestorFunds[msg.sender] == 0x0) {
        ethInvestors.push(msg.sender);
      }
      ethInvestorFunds[msg.sender] = add(ethInvestorFunds[msg.sender], toFund);

      

      hexToken.generateTokens(msg.sender, reqedHex);

      if(reFund > 0) {
        msg.sender.transfer(reFund);
      }

      

      emit SaleToken(msg.sender, msg.sender, 0, toFund, reqedHex);
    }

    
    
    
    
    
    function atxBuy(address _from, uint256 _amount) public returns(bool) {
      
      require(_amount >= 250000e18); 

      require(isInitialized);
      require(!isFinalized);

      require(_from != 0x0 && _amount != 0x0);
      require(kyc.registeredAddress(_from));
      require(maxReached() == false);
      require(onSale());

      
      require(msg.sender == atxControllerAddr);

      
      uint256 currAtxBal = atxToken.balanceOf( address(this) );
      require(currAtxBal + _amount >= currAtxBal); 

      uint256 fundingAmt = _amount;
      uint256 bonus = getPeriodBonus();
      uint256 currTotalSupply = hexToken.totalSupply();
      uint256 fundableHEXRoom = sub(maxHEXCap, currTotalSupply);
      uint256 reqedHex = atx2HexWithBonus(fundingAmt, bonus); 
      uint256 toFund;
      uint256 reFund;

      if(reqedHex > fundableHEXRoom) {
        reqedHex = fundableHEXRoom;

        toFund = hex2AtxWithBonus(reqedHex, bonus); 
        reFund = sub(fundingAmt, toFund);

        
        
        

      } else {
        toFund = fundingAmt;
        reFund = 0;
      }

      require(fundingAmt >= toFund);
      require(toFund > 0);


      
      if(atxInvestorFunds[_from] == 0x0) {
        atxInvestors.push(_from);
      }
      atxInvestorFunds[_from] = add(atxInvestorFunds[_from], toFund);

      

      hexToken.generateTokens(_from, reqedHex);

      
      
      
      
      
      
      if(reFund > 0) {
        
        if(atxChanges[_from] == 0x0) {
          atxChangeAddrs.push(_from);
        }
        atxChanges[_from] = add(atxChanges[_from], reFund);
      }

      
      
      
      
      
        
      

      emit SaleToken(msg.sender, _from, 1, toFund, reqedHex);

      return true;
    }

    function finish() public onlyOwner {
      require(!isFinalized);

      returnATXChanges();

      if(minReached()) {

        
        require(vaultWallets.length == 31);
        uint eachATX = div(atxToken.balanceOf(address(this)), vaultWallets.length);
        for(uint idx = 0; idx < vaultWallets.length; idx++) {
          
          atxToken.transfer(vaultWallets[idx], eachATX);
        }
        
        if(atxToken.balanceOf(address(this)) > 0) {
          atxToken.transfer(vaultWallets[vaultWallets.length - 1], atxToken.balanceOf(address(this)));
        }
        
        
          vaultWallets[vaultWallets.length - 1].transfer( address(this).balance );
        

        require(memWallets.length == 6);
        hexToken.generateTokens(memWallets[0], 14e26); 
        hexToken.generateTokens(memWallets[1], 84e25); 
        hexToken.generateTokens(memWallets[2], 84e25); 
        hexToken.generateTokens(memWallets[3], 80e25); 
        hexToken.generateTokens(memWallets[4], 92e25); 
        hexToken.generateTokens(memWallets[5], 80e25); 

        

      } else {
        
      }

      hexToken.finishGenerating();
      hexToken.changeController(hexControllerAddr);

      isFinalized = true;

      emit SaleFinished();
    }

    function maxReached() public view returns (bool) {
      return (hexToken.totalSupply() >= maxHEXCap);
    }

    function minReached() public view returns (bool) {
      return (hexToken.totalSupply() >= minHEXCap);
    }

    function addPeriod(uint256 _start, uint256 _end) public onlyOwner {
      require(now < _start && _start < _end);
      if (periods.length != 0) {
        
        require(periods[periods.length - 1].endTime < _start);
      }
      Period memory newPeriod;
      newPeriod.startTime = _start;
      newPeriod.endTime = _end;
      newPeriod.bonus = 0;
      if(periods.length == 0) {
        newPeriod.bonus = 50; 
      }
      else if(periods.length == 1) {
        newPeriod.bonus = 30; 
      }
      else if(periods.length == 2) {
        newPeriod.bonus = 20; 
      }
      else if (periods.length == 3) {
        newPeriod.bonus = 15; 
      }
      else if (periods.length == 4) {
        newPeriod.bonus = 10; 
      }
      else if (periods.length == 5) {
        newPeriod.bonus = 5; 
      }

      periods.push(newPeriod);
    }

    function getPeriodBonus() public view returns (uint256) {
      bool nowOnSale;
      uint256 currentPeriod;

      for (uint i = 0; i < periods.length; i++) {
        if (periods[i].startTime <= now && now <= periods[i].endTime) {
          nowOnSale = true;
          currentPeriod = i;
          break;
        }
      }

      require(nowOnSale);
      return periods[currentPeriod].bonus;
    }

    function eth2HexWithBonus(uint256 _eth, uint256 bonus) public view returns(uint256) {
      uint basic = mul(_eth, ethRate);
      return div(mul(basic, add(bonus, 100)), 100);
      
    }

    function hex2EthWithBonus(uint256 _hex, uint256 bonus) public view returns(uint256)  {
      return div(mul(_hex, 100), mul(ethRate, add(100, bonus)));
      
    }

    function atx2HexWithBonus(uint256 _atx, uint256 bonus) public view returns(uint256)  {
      uint basic = mul(_atx, atxRate);
      return div(mul(basic, add(bonus, 100)), 100);
      
    }

    function hex2AtxWithBonus(uint256 _hex, uint256 bonus) public view returns(uint256)  {
      return div(mul(_hex, 100), mul(atxRate, add(100, bonus)));
      
    }

    function onSale() public view returns (bool) {
      bool nowOnSale;

      
      for (uint i = 1; i < periods.length; i++) {
        if (periods[i].startTime <= now && now <= periods[i].endTime) {
          nowOnSale = true;
          break;
        }
      }

      return nowOnSale;
    }

    function atxChangeAddrCount() public view returns(uint256) {
      return atxChangeAddrs.length;
    }

    function returnATXChanges() public onlyOwner {
      

      for(uint256 i=0; i<atxChangeAddrs.length; i++) {
        if(atxChanges[atxChangeAddrs[i]] > 0) {
            if( atxToken.transfer(atxChangeAddrs[i], atxChanges[atxChangeAddrs[i]]) ) {
              atxChanges[atxChangeAddrs[i]] = 0x0;
            }
        }
      }
    }

    
    
    function claimTokens(address _claimToken) public onlyOwner {

      if (hexToken.controller() == address(this)) {
           hexToken.claimTokens(_claimToken);
      }

      if (_claimToken == 0x0) {
          owner.transfer(address(this).balance);
          return;
      }

      ERC20Basic claimToken = ERC20Basic(_claimToken);
      uint256 balance = claimToken.balanceOf( address(this) );
      claimToken.transfer(owner, balance);

      emit ClaimedTokens(_claimToken, owner, balance);
    }

    
    

    event SaleToken(address indexed _sender, address indexed _investor, uint256 indexed _fundType, uint256 _toFund, uint256 _hexTokens);
    event ClaimedTokens(address indexed _claimToken, address indexed owner, uint256 balance);
    event SaleFinished();
  }