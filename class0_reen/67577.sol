contract ERC20Token {
    








    
    uint256 public totalSupply;

    
    
    function balanceOf(address _owner) constant returns (uint256 balance);

    
    
    
    
    function transfer(address _to, uint256 _value) returns (bool success);

    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    
    
    
    
    function approve(address _spender, uint256 _value) returns (bool success);

    
    
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract NCSToken is StandardToken, Owned {
    
    string public constant name = "Niu Coin System";
    string public constant symbol = "NCS";
    string public version = "1.0";
    uint256 public constant decimals = 8;
    bool public disabled = false;
    uint256 public constant MILLION = (10**6 * 10**decimals);
    
    function NCSToken(uint256 _amount) {
        totalSupply = 500 * MILLION; 
        balances[msg.sender] = _amount;
    }

    function getNCSTotalSupply() external constant returns(uint256) {
        return totalSupply;
    }

    function setDisabled(bool flag) external onlyOwner {
        disabled = flag;
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        require(!disabled);
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(!disabled);
        return super.transferFrom(_from, _to, _value);
    }
    function kill() external onlyOwner {
        selfdestruct(owner);
    }
}