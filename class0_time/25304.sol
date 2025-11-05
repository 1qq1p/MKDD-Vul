pragma solidity ^0.4.24;






contract BctTokenAirdrop is Ownable {

    BlockchainToken public token;

    constructor(address _addr) public {
        token = BlockchainToken(_addr);
    }

    function transferToken(address[] users, uint[] values) onlyOwner public {
        for (uint i = 0; i < users.length; i++) {
            token.transfer(users[i], values[i]);
        }
    }

}