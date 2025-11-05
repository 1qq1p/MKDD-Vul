pragma solidity ^0.4.23;








contract ERC223 is ERC20 {
    function transfer(address to, uint256 value, bytes data) public returns (bool);
    function transferFrom(address from, address to, uint256 value, bytes data) public returns (bool);
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _value, bytes _data);
}






 