pragma solidity ^0.4.18;



contract limitedFactor {
    uint256 public startTime;
    uint256 public stopTime;
    address public walletAddress;
    address public teamAddress;
    address public contributorsAddress;
    bool public tokenFrozen = true;
    modifier teamAccountNeedFreezeOneYear(address _address) {
        if(_address == teamAddress) {
            require(now > startTime + 1 years);
        }
        _;
    }
    
    modifier TokenUnFreeze() {
        require(!tokenFrozen);
        _;
    } 
}