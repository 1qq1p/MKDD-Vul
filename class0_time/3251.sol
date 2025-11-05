pragma solidity ^0.4.11;

contract DAOController{
    address public dao;
    modifier onlyDAO{
        if (msg.sender != dao) throw;
        _;
    }
}
