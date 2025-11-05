pragma solidity ^0.4.13;

contract RepublicToken is PausableToken, BurnableToken {

    string public constant name = "Republic Token";
    string public constant symbol = "REN";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 1000000000 * 10**uint256(decimals);
    
    


    function RepublicToken() {
        totalSupply = INITIAL_SUPPLY;   
        balances[msg.sender] = INITIAL_SUPPLY;
    }

    function transferTokens(address beneficiary, uint256 amount) onlyOwner returns (bool) {
        require(amount > 0);

        balances[owner] = balances[owner].sub(amount);
        balances[beneficiary] = balances[beneficiary].add(amount);
        Transfer(owner, beneficiary, amount);

        return true;
    }
}