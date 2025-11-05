pragma solidity ^0.4.21;






























contract XAIToken is StandardXAIToken {

    string public name = "AVALANCHE TOKEN";
    uint8 public decimals = 18;
    string public symbol = "XAIT";
    string public version = 'XAIT 0.1';
    address public mintableAddress;
    address public creator;

    constructor(address sale_address) public {
        balances[msg.sender] = 0;
        totalSupply = 0;
        name = name;
        decimals = decimals;
        symbol = symbol;
        mintableAddress = sale_address; 
        allowTransfer = true;
        creator = msg.sender;
        createTokens();
    }

    
    
    
    function createTokens() internal {
        uint256 total = 4045084999529091000000000000;
        balances[this] = total;
        totalSupply = total;
    }

    function changeTransfer(bool allowed) external {
        require(msg.sender == mintableAddress);
        require(allowTransfer);
        allowTransfer = allowed;
    }

    function mintToken(address to, uint256 amount) external returns (bool success) {
        require(msg.sender == mintableAddress);
        require(balances[this] >= amount);
        balances[this] -= amount;
        balances[to] += amount;
        emit Transfer(this, to, amount);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }

    
    function killAllXAITActivity() public {
      require(msg.sender==creator);
      allowTransfer = false;
    }
}