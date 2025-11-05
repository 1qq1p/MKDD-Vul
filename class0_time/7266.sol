pragma solidity ^0.4.11;






contract AtacToken is StandardToken {

    string public constant name = "Atlantic Coin";
    string public constant symbol = "ATAC";
    uint8 public constant decimals = 18;
    
    uint256 public constant INITIAL_SUPPLY = 500 * (10 ** 6) * (10 ** 18);

    


    function AtacToken() {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
  
    function getTotalSupply() public returns (uint256) {
        return totalSupply;
    }
}