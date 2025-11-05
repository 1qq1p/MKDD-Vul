


















pragma solidity ^0.4.18;








contract depositofferToken is 
    ReentryProtected,
    ERC20Token,
    depositofferTokenAbstract,
    depositofferTokenConfig
{
    using SafeMath for uint;





    
    uint public constant TOKENS_PER_ETH = TOKENS_PER_USD * USD_PER_ETH;
    uint public constant MIN_ETH_FUND   = 1 ether * MIN_USD_FUND / USD_PER_ETH;
    uint public constant MAX_ETH_FUND   = 1 ether * MAX_USD_FUND / USD_PER_ETH;
    uint public constant KYC_ETH_LMT    = 1 ether * KYC_USD_LMT  / USD_PER_ETH;

    
    uint public END_DATE  = START_DATE + FUNDING_PERIOD;





    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }





    
    function depositofferToken()
    {
        
        
        require(bytes(symbol).length > 0);
        require(bytes(name).length > 0);
        require(owner != 0x0);
        require(fundWallet != 0x0);
        require(TOKENS_PER_USD > 0);
        require(USD_PER_ETH > 0);
        require(MIN_USD_FUND > 0);
        require(MAX_USD_FUND > MIN_USD_FUND);
        require(START_DATE > 0);
        require(FUNDING_PERIOD > 0);
        
        
        totalSupply = MAX_TOKENS * 1e18;
        balances[fundWallet] = totalSupply;
        Transfer(0x0, fundWallet, totalSupply);
    }
    
    
    function ()
        payable
    {
        
        
        proxyPurchase(msg.sender);
    }





    
    function fundFailed() public constant returns (bool)
    {
        return !__abortFuse
            || (now > END_DATE && etherRaised < MIN_ETH_FUND);
    }
    
    
    function fundSucceeded() public constant returns (bool)
    {
        return !fundFailed()
            && etherRaised >= MIN_ETH_FUND;
    }

    
    function ethToUsd(uint _wei) public constant returns (uint)
    {
        return USD_PER_ETH.mul(_wei).div(1 ether);
    }
    
    
    function usdToEth(uint _usd) public constant returns (uint)
    {
        return _usd.mul(1 ether).div(USD_PER_ETH);
    }
    
    
    function usdRaised() public constant returns (uint)
    {
        return ethToUsd(etherRaised);
    }
    
    
    function ethToTokens(uint _wei) public constant returns (uint)
    {
        uint usd = ethToUsd(_wei);
        
        
        uint bonus = 0;
    
    
    
    
    
    
    
        
        
        return _wei.mul(TOKENS_PER_ETH).mul(bonus + 100).div(100);
    }





    
    
    
    function abort()
        public
        noReentry
        onlyOwner
        returns (bool)
    {
        require(!icoSuccessful);
        delete __abortFuse;
        return true;
    }
    
    
    function proxyPurchase(address _addr)
        payable
        noReentry
        returns (bool)
    {
        require(!fundFailed());
        require(!icoSuccessful);
        require(now <= END_DATE);
        require(msg.value > 0);
        
        
        if(!kycAddresses[_addr])
        {
            require(now >= START_DATE);
            require((etherContributed[_addr].add(msg.value)) <= KYC_ETH_LMT);
        }

        
        uint tokens = ethToTokens(msg.value);
        
        
        
        xfer(fundWallet, _addr, tokens);
        
        
        etherContributed[_addr] = etherContributed[_addr].add(msg.value);
        
        
        etherRaised = etherRaised.add(msg.value);
        
        
        require(etherRaised <= MAX_ETH_FUND);

        return true;
    }
    
    
    function addKycAddress(address _addr, bool _kyc)
    public
        noReentry
        onlyOwner
        returns (bool)
    {
       require(!fundFailed());

        kycAddresses[_addr] = _kyc;
        KYCAddress(_addr, _kyc);
      return true;
    }
    
    
    
    
    
 
    
    function finaliseICO()
        public
        onlyOwner
        preventReentry()
        returns (bool)
    {
        require(fundSucceeded());

        icoSuccessful = true;

        FundsTransferred(fundWallet, this.balance);
        fundWallet.transfer(this.balance);
        return true;
    }
    
    
    function refund(address _addr)
        public
        preventReentry()
        returns (bool)
    {
        require(fundFailed());
        
        uint value = etherContributed[_addr];

        
        
        xfer(_addr, fundWallet, balances[_addr]);

        
        delete etherContributed[_addr];
        delete kycAddresses[_addr];
        
        Refunded(_addr, value);
        if (value > 0) {
            _addr.transfer(value);
        }
        return true;
    }





    function transfer(address _to, uint _amount)
        public
        preventReentry
        returns (bool)
    {
        
        require(icoSuccessful);
        super.transfer(_to, _amount);

        if (_to == deposito)
            
            require(Notify(deposito).notify(msg.sender, _amount));
        return true;
    }

    function transferFrom(address _from, address _to, uint _amount)
        public
        preventReentry
        returns (bool)
    {
        
        require(icoSuccessful);
        super.transferFrom(_from, _to, _amount);

        if (_to == deposito)
            
            require(Notify(deposito).notify(msg.sender, _amount));
        return true;
    }
    
    function approve(address _spender, uint _amount)
        public
        noReentry
        returns (bool)
    {
        
        require(icoSuccessful);
        super.approve(_spender, _amount);
        return true;
    }





    
    function changeOwner(address _newOwner)
        public
        noReentry
        onlyOwner
        returns (bool)
    {
        ChangeOwnerTo(_newOwner);
        newOwner = _newOwner;
        return true;
    }

    
    function acceptOwnership()
        public
        noReentry
        returns (bool)
    {
        require(msg.sender == newOwner);
        ChangedOwner(owner, newOwner);
        owner = newOwner;
        return true;
    }

    
    
    function changedeposito(address _addr)
        public
        noReentry
        onlyOwner
        returns (bool)
    {
        deposito = _addr;
        return true;
    }
    
    
    function destroy()
        public
        noReentry
        onlyOwner
    {
        require(!__abortFuse);
        require(this.balance == 0);
        selfdestruct(owner);
    }
    
    
    function transferAnyERC20Token(address tokenAddress, uint amount)
        public
        onlyOwner
        preventReentry
        returns (bool) 
    {
        require(ERC20Token(tokenAddress).transfer(owner, amount));
        return true;
    }
}


interface Notify
{
    event Notified(address indexed _from, uint indexed _amount);
    
    function notify(address _from, uint _amount) public returns (bool);
}

