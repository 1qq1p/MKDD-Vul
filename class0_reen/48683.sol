pragma solidity ^0.4.18;

interface PaymentGateway {

}

contract Administrated {
    address public administrator;

    modifier onlyAdministrator() {
        require(administrator == tx.origin);
        _;
    }

    modifier notAdministrator() {
        require(administrator != tx.origin);
        _;
    }

    function setAdministrator(address _administrator)
        internal
    {
        administrator = _administrator;
    }
}

interface ERC20 {
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    function totalSupply() public constant returns (uint);
    function balanceOf(address _owner) public constant returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint remaining);
}
