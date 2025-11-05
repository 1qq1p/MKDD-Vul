pragma solidity ^0.4.13;

interface TokenERC20 {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    function balanceOf(address _owner) constant returns (uint256 balance);
}


interface TokenNotifier {

    function receiveApproval(address from, uint256 _amount, address _token, bytes _data);
}





contract Owned {

    address owner;
    
    function Owned() { owner = msg.sender; }

    modifier onlyOwner { require(msg.sender == owner); _; }
}

