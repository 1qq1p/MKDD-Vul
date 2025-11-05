

pragma solidity ^0.4.24;

contract TokenFactoryInterface {
    function create(string _name, string _symbol) public returns (FactoryTokenInterface);
}



pragma solidity ^0.4.24;

