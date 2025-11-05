pragma solidity ^0.4.24;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
 
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }
 
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
 
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Controlled is Owned{
 
	
    constructor() public {
       setExclude(msg.sender,true);
    }
 
    
    bool public transferEnabled = true;
 
    
    bool lockFlag=true;
	
    mapping(address => bool) locked;
	
    mapping(address => bool) exclude;
 
	
    function enableTransfer(bool _enable) public onlyOwner returns (bool success){
        transferEnabled=_enable;
		return true;
    }
 
	
    function disableLock(bool _enable) public onlyOwner returns (bool success){
        lockFlag=_enable;
        return true;
    }
 
	
    function addLock(address _addr) public onlyOwner returns (bool success){
        require(_addr!=msg.sender);
        locked[_addr]=true;
        return true;
    }
 
	
    function setExclude(address _addr,bool _enable) public onlyOwner returns (bool success){
        exclude[_addr]=_enable;
        return true;
    }
 
	
    function removeLock(address _addr) public onlyOwner returns (bool success){
        locked[_addr]=false;
        return true;
    }
	
    modifier transferAllowed(address _addr) {
        if (!exclude[_addr]) {
            require(transferEnabled,"transfer is not enabeled now!");
            if(lockFlag){
                require(!locked[_addr],"you are locked!");
            }
        }
        _;
    }
 
}
