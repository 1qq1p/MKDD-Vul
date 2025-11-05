pragma solidity ^0.4.24;




contract VestingTrustee is Ownable {
    using SafeMath for uint256;

    
    VeganCoin public veganCoin;

    struct Grant {
        uint256 value;
        uint256 start;
        uint256 cliff;
        uint256 end;
        uint256 transferred;
        bool revokable;
    }

    
    mapping (address => Grant) public grants;

    
    uint256 public totalVesting;

    event NewGrant(address indexed _from, address indexed _to, uint256 _value);
    event UnlockGrant(address indexed _holder, uint256 _value);
    event RevokeGrant(address indexed _holder, uint256 _refund);

    
    
    constructor(VeganCoin _veganCoin) public {
        require(_veganCoin != address(0));

        veganCoin = _veganCoin;
    }

    
    
    
    
    
    
    
    function grant(address _to, uint256 _value, uint256 _start, uint256 _cliff, uint256 _end, bool _revokable)
        public ownerOnly {
        require(_to != address(0));
        require(_value > 0);

        
        require(grants[_to].value == 0);

        
        require(_start <= _cliff && _cliff <= _end);

        
        require(totalVesting.add(_value) <= veganCoin.balanceOf(address(this)));

        
        grants[_to] = Grant({
            value: _value,
            start: _start,
            cliff: _cliff,
            end: _end,
            transferred: 0,
            revokable: _revokable
        });

        
        totalVesting = totalVesting.add(_value);

        emit NewGrant(msg.sender, _to, _value);
    }

    
    
    function revoke(address _holder) public ownerOnly {
        Grant storage grant = grants[_holder];

        require(grant.revokable);

        
        uint256 refund = grant.value.sub(grant.transferred);

        
        delete grants[_holder];

        totalVesting = totalVesting.sub(refund);

        emit RevokeGrant(_holder, refund);
    }

    
    
    
    
    function vestedTokens(address _holder, uint256 _time) public constant returns (uint256) {
        Grant storage grant = grants[_holder];
        if (grant.value == 0) {
            return 0;
        }

        return calculateVestedTokens(grant, _time);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function calculateVestedTokens(Grant _grant, uint256 _time) private pure returns (uint256) {
        
        if (_time < _grant.cliff) {
            return 0;
        }

        
        if (_time >= _grant.end) {
            return _grant.value;
        }

        
         return _grant.value.mul(_time.sub(_grant.start)).div(_grant.end.sub(_grant.start));
    }

    
    
    function unlockVestedTokens() public {
        Grant storage grant = grants[msg.sender];
        require(grant.value != 0);

        
        uint256 vested = calculateVestedTokens(grant, now);
        if (vested == 0) {
            return;
        }

        
        uint256 transferable = vested.sub(grant.transferred);
        if (transferable == 0) {
            return;
        }

        grant.transferred = grant.transferred.add(transferable);
        totalVesting = totalVesting.sub(transferable);
        veganCoin.transfer(msg.sender, transferable);

        emit UnlockGrant(msg.sender, transferable);
    }
}