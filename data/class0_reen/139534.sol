pragma solidity ^0.4.24;










library PopoDatasets {

  struct Order {
    uint256 pID;
    uint256 createTime;
    uint256 createDayIndex;
    uint256 orderValue;
    uint256 refund;
    uint256 withdrawn;
    bool hasWithdrawn;
  }
  
  struct Player {
    address addr;
    bytes32 name;

    bool inviteEnable;
    uint256 inviterPID;
    uint256 [] inviteePIDs;
    uint256 inviteReward1;
    uint256 inviteReward2;
    uint256 inviteReward3;
    uint256 inviteRewardWithdrawn;

    uint256 [] oIDs;
    uint256 lastOrderDayIndex;
    uint256 dayEthIn;
  }

}
contract PopoEvents {

  event onEnableInvite
  (
    uint256 pID,
    address pAddr,
    bytes32 pName,
    uint256 timeStamp
  );
  

  event onSetInviter
  (
    uint256 pID,
    address pAddr,
    uint256 indexed inviterPID,
    address indexed inviterAddr,
    bytes32 indexed inviterName,
    uint256 timeStamp
  );

  event onOrder
  (
    uint256 indexed pID,
    address indexed pAddr,
    uint256 indexed dayIndex,
    uint256 oID,
    uint256 value,
    uint256 timeStamp
  );

  event onWithdrawOrderRefund
  (
    uint256 indexed pID,
    address indexed pAddr,
    uint256 oID,
    uint256 value,
    uint256 timeStamp
  );

  event onWithdrawOrderRefundToOrder
  (
    uint256 indexed pID,
    address indexed pAddr,
    uint256 oID,
    uint256 value,
    uint256 timeStamp
  );

  event onWithdrawInviteReward
  (
    uint256 indexed pID,
    address indexed pAddr,
    uint256 value,
    uint256 timeStamp
  );

  event onWithdrawInviteRewardToOrder
  (
    uint256 indexed pID,
    address indexed pAddr,
    uint256 value,
    uint256 timeStamp
  );
    
}
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
library NameFilter {
  
    using SafeMath for *;

    









    function nameFilter(string _input)
        internal
        pure
        returns(bytes32)
    {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;
        
        
        require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
        
        require(_temp[0] != 0x20 && _temp[_length.sub(1)] != 0x20, "string cannot start or end with space");
        
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }
        
        
        bool _hasNonNumber;
        
        
        for (uint256 i = 0; i < _length; i = i.add(1))
        {
            
            if (_temp[i] > 0x40 && _temp[i] < 0x5b)
            {
                
                _temp[i] = byte(uint(_temp[i]) + 32);
                
                
                if (_hasNonNumber == false)
                    _hasNonNumber = true;
            } else {
                require
                (
                    
                    _temp[i] == 0x20 || 
                    
                    (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
                    
                    (_temp[i] > 0x2f && _temp[i] < 0x3a),
                    "string contains invalid characters"
                );
                
                if (_temp[i] == 0x20)
                    require(_temp[i.add(1)] != 0x20, "string cannot contain consecutive spaces");
                
                
                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
                    _hasNonNumber = true;    
            }
        }
        
        require(_hasNonNumber == true, "string cannot be only numbers");
        
        bytes32 _ret;
        assembly {
            _ret := mload(add(_temp, 32))
        }
        return (_ret);
    }
}