pragma solidity ^0.4.25; 










library SafeMath {

  


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    
    
    
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  


  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
    return _a / _b;
  }

  


  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  


  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}






contract PlatinToken is HoldersToken, NoOwner, Authorizable, Pausable {
    using SafeMath for uint256;

    string public constant name = "Platin Token"; 
    string public constant symbol = "PTNX"; 
    uint8 public constant decimals = 18; 
 
    
    struct Lockup {
        uint256 release; 
        uint256 amount; 
    }

    
    mapping (address => Lockup[]) public lockups;

    
    mapping (address => mapping (address => Lockup[])) public refundable;

    
    mapping (address => mapping (address => mapping (uint256 => uint256))) public indexes;    

    
    PlatinTGE public tge;

    
    event Allocate(address indexed to, uint256 amount);

    
    event SetLockups(address indexed to, uint256 amount, uint256 fromIdx, uint256 toIdx);

    
    event Refund(address indexed from, address indexed to, uint256 amount);

    
    modifier spotTransfer(address _from, uint256 _value) {
        require(_value <= balanceSpot(_from), "Attempt to transfer more than balance spot.");
        _;
    }

    
    modifier onlyTGE() {
        require(msg.sender == address(tge), "Only TGE method.");
        _;
    }

    



    function setTGE(PlatinTGE _tge) external onlyOwner {
        require(tge == address(0), "TGE is already set.");
        require(_tge != address(0), "TGE address can't be zero.");
        tge = _tge;
        authorize(_tge);
    }        

    



 
    function allocate(address _to, uint256 _amount) external onlyTGE {
        require(_to != address(0), "Allocate To address can't be zero");
        require(_amount > 0, "Allocate amount should be > 0.");
       
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        _addHolder(_to);

        require(totalSupply_ <= tge.TOTAL_SUPPLY(), "Can't allocate more than TOTAL SUPPLY.");

        emit Allocate(_to, _amount);
        emit Transfer(address(0), _to, _amount);
    }  

    





    function transfer(address _to, uint256 _value) public whenNotPaused spotTransfer(msg.sender, _value) returns (bool) {
        return super.transfer(_to, _value);
    }

    






    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused spotTransfer(_from, _value) returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    








    function transferWithLockup(
        address _to, 
        uint256 _value, 
        uint256[] _lockupReleases,
        uint256[] _lockupAmounts,
        bool _refundable
    ) 
    public onlyAuthorized returns (bool)
    {        
        transfer(_to, _value);
        _lockup(_to, _value, _lockupReleases, _lockupAmounts, _refundable); 
    }       

    









    function transferFromWithLockup(
        address _from, 
        address _to, 
        uint256 _value, 
        uint256[] _lockupReleases,
        uint256[] _lockupAmounts,
        bool _refundable
    ) 
    public onlyAuthorized returns (bool)
    {
        transferFrom(_from, _to, _value);
        _lockup(_to, _value, _lockupReleases, _lockupAmounts, _refundable); 
    }     

    




    function refundLockedUp(
        address _from
    )
    public onlyAuthorized returns (uint256)
    {
        address _sender = msg.sender;
        uint256 _balanceRefundable = 0;
        uint256 _refundableLength = refundable[_from][_sender].length;
        if (_refundableLength > 0) {
            uint256 _lockupIdx;
            for (uint256 i = 0; i < _refundableLength; i++) {
                if (refundable[_from][_sender][i].release > block.timestamp) { 
                    _balanceRefundable = _balanceRefundable.add(refundable[_from][_sender][i].amount);
                    refundable[_from][_sender][i].release = 0;
                    refundable[_from][_sender][i].amount = 0;
                    _lockupIdx = indexes[_from][_sender][i];
                    lockups[_from][_lockupIdx].release = 0;
                    lockups[_from][_lockupIdx].amount = 0;       
                }    
            }

            if (_balanceRefundable > 0) {
                _preserveHolders(_from, _sender, _balanceRefundable);
                balances[_from] = balances[_from].sub(_balanceRefundable);
                balances[_sender] = balances[_sender].add(_balanceRefundable);
                emit Refund(_from, _sender, _balanceRefundable);
                emit Transfer(_from, _sender, _balanceRefundable);
            }
        }
        return _balanceRefundable;
    }

    




    function lockupsCount(address _who) public view returns (uint256) {
        return lockups[_who].length;
    }

    




    function hasLockups(address _who) public view returns (bool) {
        return lockups[_who].length > 0;
    }

    




    function balanceLockedUp(address _who) public view returns (uint256) {
        uint256 _balanceLokedUp = 0;
        uint256 _lockupsLength = lockups[_who].length;
        for (uint256 i = 0; i < _lockupsLength; i++) {
            if (lockups[_who][i].release > block.timestamp) 
                _balanceLokedUp = _balanceLokedUp.add(lockups[_who][i].amount);
        }
        return _balanceLokedUp;
    }

    





    function balanceRefundable(address _who, address _sender) public view returns (uint256) {
        uint256 _balanceRefundable = 0;
        uint256 _refundableLength = refundable[_who][_sender].length;
        if (_refundableLength > 0) {
            for (uint256 i = 0; i < _refundableLength; i++) {
                if (refundable[_who][_sender][i].release > block.timestamp) 
                    _balanceRefundable = _balanceRefundable.add(refundable[_who][_sender][i].amount);
            }
        }
        return _balanceRefundable;
    }

    




    function balanceSpot(address _who) public view returns (uint256) {
        uint256 _balanceSpot = balanceOf(_who);
        _balanceSpot = _balanceSpot.sub(balanceLockedUp(_who));
        return _balanceSpot;
    }

    






     
    function _lockup(
        address _who, 
        uint256 _amount, 
        uint256[] _lockupReleases,
        uint256[] _lockupAmounts,
        bool _refundable) 
    internal 
    {
        require(_lockupReleases.length == _lockupAmounts.length, "Length of lockup releases and amounts lists should be equal.");
        require(_lockupReleases.length.add(lockups[_who].length) <= 1000, "Can't be more than 1000 lockups per address.");
        if (_lockupReleases.length > 0) {
            uint256 _balanceLokedUp = 0;
            address _sender = msg.sender;
            uint256 _fromIdx = lockups[_who].length;
            uint256 _toIdx = _fromIdx + _lockupReleases.length - 1;
            uint256 _lockupIdx;
            uint256 _refundIdx;
            for (uint256 i = 0; i < _lockupReleases.length; i++) {
                if (_lockupReleases[i] > block.timestamp) { 
                    lockups[_who].push(Lockup(_lockupReleases[i], _lockupAmounts[i]));
                    _balanceLokedUp = _balanceLokedUp.add(_lockupAmounts[i]);
                    if (_refundable) {
                        refundable[_who][_sender].push(Lockup(_lockupReleases[i], _lockupAmounts[i]));
                        _lockupIdx = lockups[_who].length - 1;
                        _refundIdx = refundable[_who][_sender].length - 1;
                        indexes[_who][_sender][_refundIdx] = _lockupIdx;
                    }
                }
            }

            require(_balanceLokedUp <= _amount, "Can't lockup more than transferred amount.");
            emit SetLockups(_who, _amount, _fromIdx, _toIdx); 
        }            
    }      
}








