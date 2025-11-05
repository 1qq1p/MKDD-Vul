pragma solidity ^0.4.19;




contract NeoToken is ERC20Interface, Owned{
    using SafeMath for uint;

    string public symbol;
    string public name;
    uint8 public decimals;
    uint public _totalSupply;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    
    
    
    function NeoToken() public{
        owner = 0x0c4BdfE0aEbF69dE4975a957A2d4FE72633BBC1a;
        symbol = "NOC";
        name = "NEO CLASSIC";
        decimals = 18;
        _totalSupply = totalSupply();
        balances[owner] = _totalSupply;
        emit Transfer(address(0),owner,_totalSupply);
    }

    function totalSupply() public constant returns (uint){ 
       return 200000000 * 10**uint(decimals);
    }

    
    
    
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    
    
    
    
    
    function transfer(address to, uint tokens) public returns (bool success){
        
        require(to != 0x0);
        require(balances[msg.sender] >= tokens );
        require(balances[to] + tokens >= balances[to]);
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender,to,tokens);
        return true;
    }
    
    function buyToken(address to, uint tokens) public returns (bool success) {
        tokenPurchase(to, tokens);
        return true;
    }
    
    function tokenPurchase(address to, uint tokens) internal {
        
        require(to != 0x0);
        require(balances[owner] >= tokens );
        require(balances[to] + tokens >= balances[to]);
        balances[owner] = balances[owner].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(owner,to,tokens);
    } 
    
    
    
    
    function approve(address spender, uint tokens) public returns (bool success){
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
    }

    
    
    
    
    
    
    
    
    
    function transferFrom(address from, address to, uint tokens) public returns (bool success){
        require(tokens <= allowed[from][msg.sender]); 
        require(balances[from] >= tokens);
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        emit Transfer(from,to,tokens);
        return true;
    }

    
    
    
    
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

}