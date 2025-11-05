pragma solidity ^0.4.24;





contract Freezable is Ownable {

    mapping(address => bool) public frozenAccount;

    


    modifier isFreezenAccount(){
        require(frozenAccount[msg.sender]);
        _;
    }

    


    modifier isNonFreezenAccount(){
        require(!frozenAccount[msg.sender]);
        _;
    }

    




    function freezeAccount(address _address, bool _freeze) onlyOwner public {
        frozenAccount[_address] = _freeze;
    }

    



    function freezeAccounts(address[] _addresses) public onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            frozenAccount[_addresses[i]] = true;
        }
    }

    



    function unFreezeAccounts(address[] _addresses) public onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            frozenAccount[_addresses[i]] = false;
        }
    }

}





