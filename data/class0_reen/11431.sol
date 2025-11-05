pragma solidity ^0.4.24;






contract TMNK is StandardToken, Claimable, BurnableToken {
    using SafeMath for uint256;

    string public constant name = "TMNK";
    string public constant symbol = "TMNK";
    uint8 public constant decimals = 18;

    uint256 public constant INITIAL_SUPPLY = 2800000 * (10 ** uint256(decimals));

    


    constructor () public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }

    


    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Basic(tokenAddress).transfer(owner, tokens);
    }
}