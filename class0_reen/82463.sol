pragma solidity ^0.4.13;

contract BtzReceiver {
    using SafeMath for *;

    
    BtzToken BTZToken;
    address public tokenAddress = 0x0;
    address public owner;
    uint numUsers;

    
    struct UserInfo {
        uint totalDepositAmount;
        uint totalDepositCount;
        uint lastDepositAmount;
        uint lastDepositTime;
    }

    event DepositReceived(uint indexed _who, uint _value, uint _timestamp);
    event Withdrawal(address indexed _withdrawalAddress, uint _value, uint _timestamp);

    
    mapping (uint => UserInfo) userInfo;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function setOwner(address _addr) public onlyOwner {
        owner = _addr;
    }

    




    function setTokenContractAddress(address _tokenAddress) public onlyOwner {
        tokenAddress = _tokenAddress;
        BTZToken = BtzToken(_tokenAddress);
    }

    




    function userLookup(uint _uid) public view returns (uint, uint, uint, uint){
        return (userInfo[_uid].totalDepositAmount, userInfo[_uid].totalDepositCount, userInfo[_uid].lastDepositAmount, userInfo[_uid].lastDepositTime);
    }

    





    function receiveDeposit(uint _id, uint _value) public {
        require(msg.sender == tokenAddress);
        userInfo[_id].totalDepositAmount = userInfo[_id].totalDepositAmount.add(_value);
        userInfo[_id].totalDepositCount = userInfo[_id].totalDepositCount.add(1);
        userInfo[_id].lastDepositAmount = _value;
        userInfo[_id].lastDepositTime = now;
        emit DepositReceived(_id, _value, now);
    }

    




    function withdrawTokens(address _withdrawalAddr) public onlyOwner{
        uint tokensToWithdraw = BTZToken.balanceOf(this);
        BTZToken.transfer(_withdrawalAddr, tokensToWithdraw);
        emit Withdrawal(_withdrawalAddr, tokensToWithdraw, now);
    }
}
