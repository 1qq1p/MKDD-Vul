pragma solidity ^0.4.24;







contract EternalStorage is Ownable {

    struct Storage {
        mapping(uint256 => uint256) _uint;
        mapping(uint256 => address) _address;
    }

    Storage internal s;
    address allowed;

    constructor(uint _rF, address _r, address _f, address _a, address _t)

    public {
        setAddress(0, _a);
        setAddress(1, _r);
        setUint(1, _rF);
        setAddress(2, _f);
        setAddress(3, _t);
    }

    modifier onlyAllowed() {
        require(msg.sender == owner || msg.sender == allowed);
        _;
    }

    function identify(address _address) external onlyOwner {
        allowed = _address;
    }

    




    function transferOwnership(address newOwner) public onlyOwner {
        Ownable.transferOwnership(newOwner);
    }

    




    function setUint(uint256 i, uint256 v) public onlyOwner {
        s._uint[i] = v;
    }

    




    function setAddress(uint256 i, address v) public onlyOwner {
        s._address[i] = v;
    }

    



    function getUint(uint256 i) external view onlyAllowed returns (uint256) {
        return s._uint[i];
    }

    



    function getAddress(uint256 i) external view onlyAllowed returns (address) {
        return s._address[i];
    }

    function selfDestruct () external onlyOwner {
        selfdestruct(owner);
    }
}





