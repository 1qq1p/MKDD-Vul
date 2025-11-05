pragma solidity 0.4.25;
















contract NEUTRO is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    
    
    
    constructor () public {
        symbol = "NTO";
        name = "NEUTRO";
        decimals = 18;
        _totalSupply =  20000000000000000000000000;
        balances[0x5F8C6d055FaB4893e50e0e3c992449d3e0e00e5d] = _totalSupply;
        emit Transfer(address(0), 0x5F8C6d055FaB4893e50e0e3c992449d3e0e00e5d, _totalSupply);
        
    }


    
    
    
    function totalSupply() public view returns (uint) {
        return _totalSupply  - balances[address(0)];
    }


    
    
    
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    
    
    
    
    
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
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
        emit Transfer(from, to, tokens);
        return true;
    }


    
    
    
    
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
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
}