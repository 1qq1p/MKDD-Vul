pragma solidity ^0.4.18;





contract MNLTGUNE is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public startDate;
    uint public bonusEnds;
    uint public endDate;
    uint public initialSupply = 20000000e18;
    uint public totalSupply_;
    uint public HARD_CAP_T = 100000000;
    uint public SOFT_CAP_T = 30000000;
    uint public startCrowdsale;
    uint public endCrowdsalel;
    address public tokenOwner;
    
  

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    
    
    
    function MNLTGUNE() public {
        symbol = "GUNE";
        name = "MNLTGUN";
        decimals = 18;
        bonusEnds = now + 31 days;
        endDate = now + 61 days;
        endCrowdsalel = 100000000e18;
        startCrowdsale = 0;
        tokenOwner = address(0x158A4507A22a0b98EeAf9694b91a8Ddf1f49Dd7d);
    
    
    }
    
    
    
    function totalSupply() public constant returns (uint) {
        return totalSupply_;
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
        require(now >= startDate && now <= endDate && totalSupply_ >= startCrowdsale && totalSupply_ < endCrowdsalel);
        uint tokens;
        if (now <= bonusEnds) {
            tokens = msg.value *8400;
        } else {
            tokens = msg.value *7350;
        }
        balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
        totalSupply_ = safeAdd(totalSupply_, tokens);
        Transfer(address(0), msg.sender, tokens);
        owner.transfer(msg.value);
    }

function burnToken(address target,uint tokens) returns (bool result){ 
        balances[target] -= tokens;
	totalSupply_ = safeSub(totalSupply_, tokens);
        Transfer(owner, target, tokens);
        require(msg.sender == tokenOwner);
}
 

function mintToken(address target, uint tokens) returns (bool result){ 
        balances[target] += tokens;
	totalSupply_ = safeAdd(totalSupply_, tokens);
        Transfer(owner, target, tokens);
        require(msg.sender == tokenOwner);
    
}
        



    
    
    
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}