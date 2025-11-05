pragma solidity ^0.4.18;

contract AddressList is Claimable {
    string public name;
    mapping (address => bool) public onList;

    function AddressList(string _name, bool nullValue) public {
        name = _name;
        onList[0x0] = nullValue;
    }
    event ChangeWhiteList(address indexed to, bool onList);

    
    
    function changeList(address _to, bool _onList) onlyOwner public {
        require(_to != 0x0);
        if (onList[_to] != _onList) {
            onList[_to] = _onList;
            ChangeWhiteList(_to, _onList);
        }
    }
}
