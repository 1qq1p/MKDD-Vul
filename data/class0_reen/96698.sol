pragma solidity ^0.4.20;















contract IVNT3Token is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    address public ownerAddress;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => bool) public frozenAccount;

    
    
    
    constructor() public {
        symbol = "IVNT3";
        name = "IVNT3 Token";
        decimals = 18;
        _totalSupply = 969 * 10 ** 26;
        ownerAddress = 0x46a95d3d6109f5e697493ea508d6d20aff1cc13e;
        balances[ownerAddress] = _totalSupply;
        emit Transfer(address(0), ownerAddress, _totalSupply);
    }


    
    
    
    function totalSupply() public constant returns (uint) {
        return _totalSupply - balances[address(0)];
    }


    
    
    
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }


    
    
    
    
    
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        require(!frozenAccount[msg.sender]);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    
    
    
    
    
    
    
    
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    
    
    
    
    
    
    
    
    
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        require(!frozenAccount[from]);
        emit Transfer(from, to, tokens);
        return true;
    }


    
    
    
    
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    
    
    
    
    
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


    
    
    
    function () public payable {
        revert();
    }


    
    
    
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }


    
    
    
    
    
    function burn(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);   
        balances[msg.sender] -= _value;            
        _totalSupply -= _value;                    
        emit Burn(msg.sender, _value);
        return true;
    }

    
    
    
    
    
    
    
    
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value);               
        require(_value <= allowed[_from][msg.sender]);    
        balances[_from] -= _value;                        
        allowed[_from][msg.sender] -= _value;             
        _totalSupply -= _value;                           
        emit Burn(_from, _value);
        return true;
    }

    
    
    
    function freezeAccount(address target, bool freeze) public onlyOwner returns (bool success) {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
        return true;
    }
}