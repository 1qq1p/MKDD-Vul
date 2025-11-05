pragma solidity ^0.4.18;

library SafeMath {
    function add(uint a, uint b) pure internal returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }

    function sub(uint a, uint b) pure internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function mul(uint a, uint b) pure internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) pure internal returns (uint) {
        uint c = a / b;
        return c;
    }
}


contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address account) public constant returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function allowance(address owner, address spender) public constant returns (uint remaining);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed tokenOwner, address indexed spender, uint value);
}
