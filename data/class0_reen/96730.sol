pragma solidity 0.4.21;

contract StandardToken is BasicToken {

	mapping (address => mapping (address => uint256)) internal allowed;
}
