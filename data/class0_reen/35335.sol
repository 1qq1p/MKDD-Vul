contract IReceiver { 







    function tokenFallback(address _from, uint _value, bytes _data) public;
}





library LSafeMath {

    uint256 constant WAD = 1 ether;
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        if (c / a == b)
            return c;
        revert();
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > 0) { 
            uint256 c = a / b;
            return c;
        }
        revert();
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b <= a)
            return a - b;
        revert();
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        if (c >= a) 
            return c;
        revert();
    }

    function wmul(uint a, uint b) internal pure returns (uint256) {
        return add(mul(a, b), WAD / 2) / WAD;
    }

    function wdiv(uint a, uint b) internal pure returns (uint256) {
        return add(mul(a, WAD), b / 2) / b;
    }
}

contract ARCXToken is StandardToken, Ownable {
    string  public name;
    string  public symbol;
    uint    public constant decimals = 18;
    uint    public INITIAL_SUPPLY;
    address public crowdsaleContract;
    bool    public transferEnabled;
    uint public timeLock; 
    mapping(address => bool) private ingnoreLocks;
    mapping(address => uint) public lockedAddresses;


    
    event Burn(address indexed _burner, uint _value);

    modifier onlyWhenTransferEnabled() {
        if (msg.sender != crowdsaleContract) {
            require(transferEnabled);
        } 
        _;
    }
    
    modifier checktimelock() {
        require(now >= lockedAddresses[msg.sender] && (now >= timeLock || ingnoreLocks[msg.sender]));
        _;
    }
    
    function ARCXToken(uint time_lock, address crowdsale_contract, string _name, string _symbol, uint supply) public {
        INITIAL_SUPPLY = supply;
        name = _name;
        symbol = _symbol;
        address addr = (crowdsale_contract != address(0)) ? crowdsale_contract : msg.sender;
        balances[addr] = INITIAL_SUPPLY; 
        transferEnabled = true;
        totalSupply = INITIAL_SUPPLY;
        crowdsaleContract = addr; 
        timeLock = time_lock;
        ingnoreLocks[addr] = true;
        emit Transfer(address(0x0), addr, INITIAL_SUPPLY);
    }

    function setupCrowdsale(address _contract, bool _transferAllowed) public onlyOwner {
        crowdsaleContract = _contract;
        transferEnabled = _transferAllowed;
    }

    function transfer(address _to, uint _value) public
        onlyWhenTransferEnabled
        checktimelock
        returns (bool) {
            return super.transfer(_to, _value);
        }

    function transferFrom(address _from, address _to, uint _value) public
        onlyWhenTransferEnabled
        checktimelock
        returns (bool) {
            return super.transferFrom(_from, _to, _value);
        }

    function burn(uint _value) public
        onlyWhenTransferEnabled
        checktimelock
        returns (bool) {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            totalSupply = totalSupply.sub(_value);
            emit Burn(msg.sender, _value);
            emit Transfer(msg.sender, address(0x0), _value);
            return true;
        }

    
    function burnFrom(address _from, uint256 _value) public
        onlyWhenTransferEnabled
        checktimelock
        returns (bool) {
            assert(transferFrom(_from, msg.sender, _value));
            return burn(_value);
        } 

    function emergencyERC20Drain(ERC20 token, uint amount ) public onlyOwner {
        token.transfer(owner, amount);
    }
    
    function ChangeTransferStatus() public onlyOwner {
        if (transferEnabled == false) {
            transferEnabled = true;
        } else {
            transferEnabled = false;
        }
    }
    
    function setupTimelock(uint _time) public onlyOwner {
        timeLock = _time;
    }
    
    function setLockedAddress(address _holder, uint _time) public onlyOwner {
        lockedAddresses[_holder] = _time;
    }
    
    function IgnoreTimelock(address _owner) public onlyOwner {
        ingnoreLocks[_owner] = true;
    }
    
    function allowFallback(bool allow) public onlyOwner {
        isFallbackAllowed = allow;
    }

}