pragma solidity ^0.4.18;

contract AddressList is Claimable {
    event ChangeWhiteList(address indexed to, bool onList);
    function changeList(address _to, bool _onList) public;
}