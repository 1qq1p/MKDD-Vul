pragma solidity 0.4.24;






contract IndexInterface is DerivativeInterface,  ERC20PriceInterface {

    address[] public tokens;
    uint[] public weights;
    bool public supportRebalance;


    function invest() public payable returns(bool success);

    
    function rebalance() public returns (bool success);
    function getTokens() public view returns (address[] _tokens, uint[] _weights);
    function buyTokens() external returns(bool);
}
