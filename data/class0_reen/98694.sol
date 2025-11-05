pragma solidity ^0.4.24;

contract MultiOwnable {
    address public superOwner;
    mapping (address => bool) owners;
    
    event ChangeSuperOwner(address indexed newSuperOwner);
    event AddOwner(address indexed newOwner);
    event DeleteOwner(address indexed toDeleteOwner);

    constructor() public {
        superOwner = msg.sender;
        owners[superOwner] = true;
    }

    modifier onlySuperOwner() {
        require(superOwner == msg.sender);
        _;
    }

    modifier onlyOwner() {
        require(owners[msg.sender]);
        _;
    }

    function addOwner(address owner) public onlySuperOwner returns (bool) {
        require(owner != address(0));
        owners[owner] = true;
        emit AddOwner(owner);
        return true;
    }

    function deleteOwner(address owner) public onlySuperOwner returns (bool) {
        
        require(owner != address(0));
        owners[owner] = false;
        
        emit DeleteOwner(owner);
        
        return true;
    }
    function changeSuperOwner(address _superOwner) public onlySuperOwner returns(bool) {
        
        superOwner = _superOwner;
        
        emit ChangeSuperOwner(_superOwner);
        
        return true;
    }

    function chkOwner(address owner) public view returns (bool) {
        return owners[owner];
    }
}
