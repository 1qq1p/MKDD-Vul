pragma solidity ^0.4.24;












contract Vestable {

    mapping(address => uint) vestedAddresses ;    
    bool isVestingOver = false;
    event AddVestingAddress(address vestingAddress, uint maturityTimestamp);

    function addVestingAddress(address vestingAddress, uint maturityTimestamp) internal{
        vestedAddresses[vestingAddress] = maturityTimestamp;
        emit AddVestingAddress(vestingAddress, maturityTimestamp);
    }

    function checkVestingTimestamp(address testAddress) public view returns(uint){
        return vestedAddresses[testAddress];
    }

    function checkVestingCondition(address sender) internal view returns(bool) {
        uint vestingTimestamp = vestedAddresses[sender];
        if(vestingTimestamp > 0) {
            return (now > vestingTimestamp);
        }
        else {
            return true;
        }
    }

}
