pragma solidity 0.4.24;





library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}






contract BCCT is ERC20Interface {
    using SafeMath for uint;
    
    address public owner;
    string public symbol = "BCCT";
    string public name = "Beverage Cash Coin";
    uint8 public decimals = 18;
    
    uint private _totalSupply = 150425700 * 10**uint(decimals);

    mapping(address => uint) private balances;
    mapping(address => mapping(address => uint)) private allowed;
    
    constructor() public {
        owner = msg.sender;
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    
    
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    
    
    
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4); 
        _;
    }
    
    
    
    
    
    
    
    function transferQueue(address[] to, uint[] amount) public onlyOwner returns (bool success) {
        require(to.length == amount.length);
        
        for (uint64 i = 0; i < to.length; ++i) {
            _transfer(msg.sender, to[i], amount[i]);
        }
        
        return true;
    }

    
    
    
    function transferAnyERC20Token(address tokenAddress, uint tokens) 
        public 
        onlyOwner 
        onlyPayloadSize(32 + 32) 
        returns (bool success) 
    {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }

    
    
    
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }

    
    
    
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    
    
    
    
    
    function transfer(address to, uint tokens) 
        public 
        onlyPayloadSize(32 + 32) 
        returns (bool success) 
    {
        _transfer(msg.sender, to, tokens);
        return true;
    }

    
    
    
    
    
    
    
    
    function approve(address spender, uint tokens) 
        public 
        onlyPayloadSize(32 + 32) 
        returns (bool success) 
    {
        require(balances[msg.sender] >= tokens);
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    
    
    
    
    
    
    
    
    
    function transferFrom(address from, address to, uint tokens) 
        public 
        onlyPayloadSize(32 + 32 + 32) 
        returns (bool success) 
    {
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        _transfer(from, to, tokens);
        return true;
    }

    
    
    
    
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    
    
    
    
    
    function _transfer(address from, address to, uint tokens) internal {
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
    }
}