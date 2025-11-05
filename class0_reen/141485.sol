pragma solidity ^0.4.23;

contract FTFNExchangeToken is StandardToken { 

    

    





    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'H1FTFN.2018';
    uint256 public unitsOneEthCanBuy;     
    uint256 public totalEthInWei;         
    address public fundsWallet;           

    
    
    function FTFNExchangeToken() {
        balances[msg.sender] = 901000000000000000000000000000;               
        totalSupply = 701000000000000000000000000000;                        
        name = "FTFNExchangeToken";                                   
        decimals = 8;                                               
        symbol = "FTFN";                                             
        unitsOneEthCanBuy = 15000000;                                      
        fundsWallet = msg.sender;                                    
    }

    function() public payable{
        totalEthInWei = totalEthInWei + msg.value;
        uint256 amount = msg.value * unitsOneEthCanBuy;
        require(balances[fundsWallet] >= amount);

        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;

        Transfer(fundsWallet, msg.sender, amount); 

        
        fundsWallet.transfer(msg.value);                             
    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        
        
        
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}