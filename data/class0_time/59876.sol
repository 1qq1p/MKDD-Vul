












pragma solidity ^0.4.20;

contract DSTokenBase is EIP20Interface, DSMath {
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return _balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success){
        _balances[msg.sender] = sub(_balances[msg.sender], _value);
        _balances[_to] = add(_balances[_to], _value);
        
        Transfer(msg.sender, _to, _value);
        
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        if (_from != msg.sender) {
            _approvals[_from][msg.sender] = sub(_approvals[_from][msg.sender], _value);
        }
        _balances[_from] = sub(_balances[_from], _value);
        _balances[_to] = add(_balances[_to], _value);
        
        Transfer(_from, _to, _value);
        
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success){
        _approvals[msg.sender][_spender] = _value;
        
        Approval(msg.sender, _spender, _value);
        
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining){
        return _approvals[_owner][_spender];
    }
}
