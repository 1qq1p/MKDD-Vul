pragma solidity ^0.4.23;


















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







contract Taboo is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public name;
    uint8  public decimals;
    uint   public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    



    constructor() public {
        symbol          = 'TABOO';
        name            = 'Taboo Gold';
        decimals        = 6;
        _totalSupply    = 100000000 * 10 ** uint(decimals);
        balances[owner] = _totalSupply;
        
        emit Transfer(address(0), owner, _totalSupply);
    }

    



    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    



    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    





    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to]         = balances[to].add(tokens);
        
        emit Transfer(msg.sender, to, tokens);
        
        return true;
    }

    








    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);
        
        return true;
    }

    









    function transferFrom(
    	address from, address to, uint tokens) public returns (
    	bool success) {
        balances[from]            = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to]              = balances[to].add(tokens);

        emit Transfer(from, to, tokens);
        
        return true;
    }

    




    function allowance(
    	address tokenOwner, address spender) public constant returns (
    	uint remaining) {
        return allowed[tokenOwner][spender];
    }

    





    function approveAndCall(
    	address spender, uint tokens, bytes data) public returns (
    	bool success) {
        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);
        
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        
        return true;
    }

    



    function () public payable {
        revert();
    }

    



    function transferAnyERC20Token(
    	address tokenAddress, uint tokens) public onlyOwner returns (
    	bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}