pragma solidity ^0.4.25;










contract managedToken is FreezingToken{
    uint256[2] public mintLimit = [101000000 ether, 9000000 ether]; 
    uint256[2] public totalMint = [0,0];
    string public constant name = "ALE";
    string public constant symbol = "ALE";
    uint8 public constant decimals = 18;
    
    constructor(IRightAndRoles _rightAndRoles) FreezingToken(_rightAndRoles) public {}
    
    function internalMint(uint8 _type, address _account, uint256 _value) internal {
        totalMint[_type] += _value;
        require(totalMint[_type] <= mintLimit[_type]);
        super.internalMint(_type,_account,_value);
    }
    
    
    
    
    
    
    
    
    
    function setup(uint8 _withdrawPriority, uint8 _mixedType) public {
        require(rightAndRoles.onlyRoles(msg.sender,3));
        require(_withdrawPriority < 2 && _mixedType < 4);
        mixedType = _mixedType;
        withdrawPriority = _withdrawPriority;
    }
    function massMint(uint8[] _types, address[] _addreses, uint256[] _values) public {
        require(rightAndRoles.onlyRoles(msg.sender,3));
        require(_types.length == _addreses.length && _addreses.length == _values.length);
        for(uint256 i = 0; i < _types.length; i++){
            internalMint(_types[i], _addreses[i], _values[i]);
        }
    }
    function massBurn(uint8[] _types, address[] _addreses, uint256[] _values) public {
        require(rightAndRoles.onlyRoles(msg.sender,3));
        require(_types.length == _addreses.length && _addreses.length == _values.length);
        for(uint256 i = 0; i < _types.length; i++){
            internalBurn(_types[i], _addreses[i], _values[i]);
        }
    }
    
    function distribution(uint8 _type, address[] _addresses, uint256[] _values, uint256[] _when) public {
        require(rightAndRoles.onlyRoles(msg.sender,3));
        require(_addresses.length == _values.length && _values.length == _when.length);
        uint256 sumValue = 0;
        for(uint256 i = 0; i < _addresses.length; i++){
            sumValue += _values[i]; 
            uint256 _value = getBalance(_type,_addresses[i]) + _values[i];
            setBalance(_type,_addresses[i],_value);
            emit Transfer(msg.sender, _addresses[i], _values[i]);
            if(_when[i] > 0){
                _value = balanceOf(_addresses[i]);
                freeze storage _freeze = freezedTokens[_addresses[i]];
                _freeze.amount = _value;
                _freeze.when = _when[i];
            }
        }
        uint256 _balance = getBalance(_type, msg.sender);
        require(_balance >= sumValue);
        setBalance(_type,msg.sender,_balance-sumValue);
    }
}


