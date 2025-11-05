pragma solidity ^0.4.18;



















contract digithothToken is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply = 500000000;
    uint public startDate;
    uint public bonusEnds;
    uint public presaleEnds;
    uint public endDate;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    
    
    
    function digithothToken() public {
        symbol = "DGT";
        name = "digithoth Token";
        decimals = 18;
        bonusEnds = now + 2 weeks;
        presaleEnds = now + 6 weeks;
        endDate = now + 10 weeks;

    }


    
    
    
    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }


    
    
    
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }


    
    
    
    
    
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }


    
    
    
    
    
    
    
    
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }


    
    
    
    
    
    
    
    
    
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(from, to, tokens);
        return true;
    }


    
    
    
    
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    
    
    
    
    
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    
    
    
    function () public payable {
        require(now >= startDate && now <= endDate);
        uint tokens;
        if (now <= bonusEnds) {
            tokens = msg.value * 12500;
        }
        else if (now <= presaleEnds) {
            tokens = msg.value * 10000;
        }
        else {
            tokens = msg.value * 7800;
        }
        balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
        _totalSupply = safeAdd(_totalSupply, tokens);
        Transfer(address(0), msg.sender, tokens);
        owner.transfer(msg.value);
    }



    
    
    
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}