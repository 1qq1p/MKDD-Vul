pragma solidity ^0.4.18;





































library Referral {

    


    struct Node {
        
        address referrer;
        
        mapping (address => uint) invitees;
        
        address[] inviteeIndex;
        
        uint shares;
        
        bool exists;
    }

    


    struct Tree {
        
        mapping (address => Referral.Node) nodes;
        
        address[] treeIndex;
    }

    


    function getReferrer (
        Tree storage self,
        address _invitee
    )
        public
        constant
        returns (address _referrer)
    {
        _referrer = self.nodes[_invitee].referrer;
    }

    


    function getTreeSize (
        Tree storage self
    )
        public
        constant
        returns (uint _size)
    {
        _size = self.treeIndex.length;
    }

    


    function addInvitee (
        Tree storage self,
        address _referrer,
        address _invitee,
        uint _shares
    )
        internal
    {
        Node memory inviteeNode;
        inviteeNode.referrer = _referrer;
        inviteeNode.shares = _shares;
        inviteeNode.exists = true;
        self.nodes[_invitee] = inviteeNode;
        self.treeIndex.push(_invitee);

        if (self.nodes[_referrer].exists == true) {
            self.nodes[_referrer].invitees[_invitee] = _shares;
            self.nodes[_referrer].inviteeIndex.push(_invitee);
        }
    }
}

pragma solidity ^0.4.18;































library TieredPayoff {
    using SafeMath for uint;

    














    function payoff(
        Referral.Tree storage self,
        address _referrer
    )
        public
        view
        returns (uint)
    {
        Referral.Node node = self.nodes[_referrer];

        if(!node.exists) {
            return 0;
        }

        uint reward = 0;
        uint shares = 0;
        uint degree = node.inviteeIndex.length;
        uint tierPercentage = getBonusPercentage(node.inviteeIndex.length);

        
        if(degree == 0) {
            return 0;
        }

        assert(tierPercentage > 0);

        if(degree == 1) {
            shares = node.invitees[node.inviteeIndex[0]];
            reward = reward.add(shares.mul(tierPercentage).div(100));
            return reward;
        }


        
        
        
        if(degree >= 2 && degree <= 27) {
            for (uint i = 0; i < (degree - 1); i++) {
                shares = node.invitees[node.inviteeIndex[i]];
                reward = reward.add(shares.mul(1).div(100));
            }
        }

        
        shares = node.invitees[node.inviteeIndex[degree - 1]];
        reward = reward.add(shares.mul(tierPercentage).div(100));

        return reward;
    }

    



    function getBonusPercentage(
        uint _referrals
    )
        public
        pure
        returns (uint)
    {
        if (_referrals == 0) {
            return 0;
        }
        if (_referrals >= 27) {
            return 33;
        }
        return _referrals + 6;
    }
}


contract Vesting is Ownable {
    using SafeMath for uint;

    Token public vestingToken;          

    struct VestingSchedule {
        uint startTimestamp;            
        uint cliffTimestamp;            
        uint lockPeriod;                
        uint endTimestamp;              
        uint totalAmount;               
        uint amountWithdrawn;           
        address depositor;              
        bool isConfirmed;               
    }

    
    mapping (address => VestingSchedule) vestingSchedules;

    
    
    function Vesting(address _token) public {
        vestingToken = Token(_token);
    }

    function registerVestingSchedule(address _newAddress,
                                    address _depositor,
                                    uint _startTimestamp,
                                    uint _cliffTimestamp,
                                    uint _lockPeriod,
                                    uint _endTimestamp,
                                    uint _totalAmount)
        public onlyOwner
    {
        
        
        require( _depositor != 0x0 );
        require( vestingSchedules[_newAddress].depositor == 0x0 );

        
        require( _cliffTimestamp >= _startTimestamp );
        require( _endTimestamp > _cliffTimestamp );

        
        require( _lockPeriod != 0 ); 
        require( _endTimestamp.sub(_startTimestamp) > _lockPeriod );

        
        vestingSchedules[_newAddress] = VestingSchedule({
            startTimestamp: _startTimestamp,
            cliffTimestamp: _cliffTimestamp,
            lockPeriod: _lockPeriod,
            endTimestamp: _endTimestamp,
            totalAmount: _totalAmount,
            amountWithdrawn: 0,
            depositor: _depositor,
            isConfirmed: false
        });

        
        VestingScheduleRegistered(
            _newAddress,
            _depositor,
            _startTimestamp,
            _lockPeriod,
            _cliffTimestamp,
            _endTimestamp,
            _totalAmount
        );
    }

    function confirmVestingSchedule(uint _startTimestamp,
                                    uint _cliffTimestamp,
                                    uint _lockPeriod,
                                    uint _endTimestamp,
                                    uint _totalAmount)
        public
    {
        VestingSchedule storage vestingSchedule = vestingSchedules[msg.sender];

        
        require( vestingSchedule.depositor != 0x0 );
        require( vestingSchedule.isConfirmed == false );

        
        require( vestingSchedule.startTimestamp == _startTimestamp );
        require( vestingSchedule.cliffTimestamp == _cliffTimestamp );
        require( vestingSchedule.lockPeriod == _lockPeriod );
        require( vestingSchedule.endTimestamp == _endTimestamp );
        require( vestingSchedule.totalAmount == _totalAmount );

        
        vestingSchedule.isConfirmed = true;
        require(vestingToken.transferFrom(vestingSchedule.depositor, address(this), _totalAmount));

        
        VestingScheduleConfirmed(
            msg.sender,
            vestingSchedule.depositor,
            vestingSchedule.startTimestamp,
            vestingSchedule.cliffTimestamp,
            vestingSchedule.lockPeriod,
            vestingSchedule.endTimestamp,
            vestingSchedule.totalAmount
        );
    }

    function withdrawVestedTokens()
        public 
    {
        VestingSchedule storage vestingSchedule = vestingSchedules[msg.sender];

        
        require( vestingSchedule.isConfirmed == true );
        require( vestingSchedule.cliffTimestamp <= now );

        uint totalAmountVested = calculateTotalAmountVested(vestingSchedule);
        uint amountWithdrawable = totalAmountVested.sub(vestingSchedule.amountWithdrawn);
        vestingSchedule.amountWithdrawn = totalAmountVested;

        if (amountWithdrawable > 0) {
            canWithdraw(vestingSchedule, amountWithdrawable);
            require( vestingToken.transfer(msg.sender, amountWithdrawable) );
            Withdraw(msg.sender, amountWithdrawable);
        }
    }

    function calculateTotalAmountVested(VestingSchedule _vestingSchedule)
        internal view returns (uint _amountVested)
    {
        
        if (now >= _vestingSchedule.endTimestamp) {
            return _vestingSchedule.totalAmount;
        }

        
        uint durationSinceStart = now.sub(_vestingSchedule.startTimestamp);
        uint totalVestingTime = SafeMath.sub(_vestingSchedule.endTimestamp, _vestingSchedule.startTimestamp);
        uint vestedAmount = SafeMath.div(
            SafeMath.mul(durationSinceStart, _vestingSchedule.totalAmount),
            totalVestingTime
        );

        return vestedAmount;
    }

    
    function canWithdraw(VestingSchedule _vestingSchedule, uint _amountWithdrawable)
        internal view
    {
        uint lockPeriods = (_vestingSchedule.endTimestamp.sub(_vestingSchedule.startTimestamp))
                                                         .div(_vestingSchedule.lockPeriod);

        if (now < _vestingSchedule.endTimestamp) {
            require( _amountWithdrawable >= _vestingSchedule.totalAmount.div(lockPeriods) );
        }
    }

    

    function revokeSchedule(address _addressToRevoke, address _addressToRefund)
        public onlyOwner
    {
        VestingSchedule storage vestingSchedule = vestingSchedules[_addressToRevoke];

        require( vestingSchedule.isConfirmed == true );
        require( _addressToRefund != 0x0 );

        uint amountWithdrawable;
        uint amountRefundable;

        if (now < vestingSchedule.cliffTimestamp) {
            
            amountRefundable = vestingSchedule.totalAmount;

            delete vestingSchedules[_addressToRevoke];
            require( vestingToken.transfer(_addressToRefund, amountRefundable) );
        } else {
            
            uint totalAmountVested = calculateTotalAmountVested(vestingSchedule);
            amountWithdrawable = totalAmountVested.sub(vestingSchedule.amountWithdrawn);
            amountRefundable = totalAmountVested.sub(vestingSchedule.amountWithdrawn);

            delete vestingSchedules[_addressToRevoke];
            require( vestingToken.transfer(_addressToRevoke, amountWithdrawable) );
            require( vestingToken.transfer(_addressToRefund, amountRefundable) );
        }

        VestingRevoked(_addressToRevoke, amountWithdrawable, amountRefundable);
    }

    
    function changeVestingAddress(address _oldAddress, address _newAddress)
        public onlyOwner
    {
        VestingSchedule storage vestingSchedule = vestingSchedules[_oldAddress];

        require( vestingSchedule.isConfirmed == true );
        require( _newAddress != 0x0 );
        require( vestingSchedules[_newAddress].depositor == 0x0 );

        VestingSchedule memory newVestingSchedule = vestingSchedule;
        delete vestingSchedules[_oldAddress];
        vestingSchedules[_newAddress] = newVestingSchedule;

        VestingAddressChanged(_oldAddress, _newAddress);
    }

    event VestingScheduleRegistered(
        address registeredAddress,
        address depositor,
        uint startTimestamp,
        uint cliffTimestamp,
        uint lockPeriod,
        uint endTimestamp,
        uint totalAmount
    );
    event VestingScheduleConfirmed(
        address registeredAddress,
        address depositor,
        uint startTimestamp,
        uint cliffTimestamp,
        uint lockPeriod,
        uint endTimestamp,
        uint totalAmount
    );
    event Withdraw(address registeredAddress, uint amountWithdrawn);
    event VestingRevoked(address revokedAddress, uint amountWithdrawn, uint amountRefunded);
    event VestingAddressChanged(address oldAddress, address newAddress);
}









pragma solidity ^0.4.18;