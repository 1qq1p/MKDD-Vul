

















pragma solidity 0.4.24;

contract MAuthorizable is
    IAuthorizable
{
    
    event AuthorizedAddressAdded(
        address indexed target,
        address indexed caller
    );

    
    event AuthorizedAddressRemoved(
        address indexed target,
        address indexed caller
    );

    
    modifier onlyAuthorized { revert(); _; }
}
