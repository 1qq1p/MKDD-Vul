pragma solidity ^0.4.13;






contract LoggedERC20 is Ownable {
    
    struct LogValueBlock {
    uint256 value;
    uint256 block;
    }

    
    string public standard = 'LogValueBlockToken 0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    LogValueBlock[] public loggedTotalSupply;

    bool public locked;

    uint256 public creationBlock;

    
    mapping (address => LogValueBlock[]) public loggedBalances;
    mapping (address => mapping (address => uint256)) public allowance;

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    mapping (address => bool) public frozenAccount;

    
    event FrozenFunds(address target, bool frozen);

    
    function LoggedERC20(
    uint256 initialSupply,
    string tokenName,
    uint8 decimalUnits,
    string tokenSymbol,
    bool transferAllSupplyToOwner,
    bool _locked
    ) {
        LogValueBlock memory valueBlock = LogValueBlock(initialSupply, block.number);

        loggedTotalSupply.push(valueBlock);

        if(transferAllSupplyToOwner) {
            loggedBalances[msg.sender].push(valueBlock);
        }
        else {
            loggedBalances[this].push(valueBlock);
        }

        name = tokenName;                                   
        symbol = tokenSymbol;                               
        decimals = decimalUnits;                            
        locked = _locked;
    }

    function valueAt(LogValueBlock [] storage valueBlocks, uint256 block) internal returns (uint256) {
        if(valueBlocks.length == 0) {
            return 0;
        }

        LogValueBlock memory prevLogValueBlock;

        for(uint256 i = 0; i < valueBlocks.length; i++) {

            LogValueBlock memory valueBlock = valueBlocks[i];

            if(valueBlock.block > block) {
                return prevLogValueBlock.value;
            }

            prevLogValueBlock = valueBlock;
        }

        return prevLogValueBlock.value;
    }

    function setBalance(address _address, uint256 value) internal {
        loggedBalances[_address].push(LogValueBlock(value, block.number));
    }

    function totalSupply() returns (uint256) {
        return valueAt(loggedTotalSupply, block.number);
    }

    function balanceOf(address _address) returns (uint256) {
        return valueAt(loggedBalances[_address], block.number);
    }

    function transferInternal(address _from, address _to, uint256 value) internal returns (bool success) {
        uint256 balanceFrom = valueAt(loggedBalances[msg.sender], block.number);
        uint256 balanceTo = valueAt(loggedBalances[_to], block.number);

        if(value == 0) {
            return false;
        }

        if(frozenAccount[_from] == true) {
            return false;
        }

        if(balanceFrom < value) {
            return false;
        }

        if(balanceTo + value <= balanceTo) {
            return false;
        }

        loggedBalances[_from].push(LogValueBlock(balanceFrom - value, block.number));
        loggedBalances[_to].push(LogValueBlock(balanceTo + value, block.number));

        Transfer(_from, _to, value);

        return true;
    }

    
    function transfer(address _to, uint256 _value) {
        require(locked == false);

        bool status = transferInternal(msg.sender, _to, _value);

        require(status == true);
    }

    
    function approve(address _spender, uint256 _value) returns (bool success) {
        if(locked) {
            return false;
        }

        allowance[msg.sender][_spender] = _value;
        return true;
    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        if(locked) {
            return false;
        }

        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if(locked) {
            return false;
        }

        bool _success = transferInternal(_from, _to, _value);

        if(_success) {
            allowance[_from][msg.sender] -= _value;
        }

        return _success;
    }
}
