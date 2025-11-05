
pragma solidity ^0.4.24;


contract OpsManaged is Owned {

    address public opsAddress;


    constructor() public
        Owned()
    {
    }


    modifier onlyOwnerOrOps() {
        require(isOwnerOrOps(msg.sender), 'Require only owner or ops');
        _;
    }


    function isOps(address _address) public view returns (bool) {
        return (opsAddress != address(0) && _address == opsAddress);
    }


    function isOwnerOrOps(address _address) public view returns (bool) {
        return (isOwner(_address) || isOps(_address));
    }


    function setOpsAddress(address _newOpsAddress) public onlyOwner returns (bool success) {
        require(_newOpsAddress != owner, 'Require newOpsAddress != owner');
        require(_newOpsAddress != address(this), 'Require newOpsAddress != address(this)');

        opsAddress = _newOpsAddress;

        return true;
    }
}



