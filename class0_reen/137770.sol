pragma solidity ^0.4.21;








contract BOLTH is TransferLimitedToken {
    uint256 public constant SALE_END_TIME = 1536739200; 

    function BOLTH(address _listener, address[] _owners, address manager) public
        TransferLimitedToken(SALE_END_TIME, _listener, _owners, manager)
    {
        name = "BOLTH";
        symbol = "BTH";
        decimals = 18;
    }
}