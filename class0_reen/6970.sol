pragma solidity 0.5.2;




interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


contract TokenFRT is Proxied, GnosisStandardToken {
    address public owner;

    string public constant symbol = "MGN";
    string public constant name = "Magnolia Token";
    uint8 public constant decimals = 18;

    struct UnlockedToken {
        uint amountUnlocked;
        uint withdrawalTime;
    }

    


    address public minter;

    
    mapping(address => UnlockedToken) public unlockedTokens;

    
    mapping(address => uint) public lockedTokenBalances;

    



    
    
    function updateMinter(address _minter) public {
        require(msg.sender == owner, "Only the minter can set a new one");
        require(_minter != address(0), "The new minter must be a valid address");

        minter = _minter;
    }

    
    
    function updateOwner(address _owner) public {
        require(msg.sender == owner, "Only the owner can update the owner");
        require(_owner != address(0), "The new owner must be a valid address");
        owner = _owner;
    }

    function mintTokens(address user, uint amount) public {
        require(msg.sender == minter, "Only the minter can mint tokens");

        lockedTokenBalances[user] = add(lockedTokenBalances[user], amount);
        totalTokens = add(totalTokens, amount);
    }

    
    function lockTokens(uint amount) public returns (uint totalAmountLocked) {
        
        uint actualAmount = min(amount, balances[msg.sender]);

        
        balances[msg.sender] = sub(balances[msg.sender], actualAmount);
        lockedTokenBalances[msg.sender] = add(lockedTokenBalances[msg.sender], actualAmount);

        
        totalAmountLocked = lockedTokenBalances[msg.sender];
    }

    function unlockTokens() public returns (uint totalAmountUnlocked, uint withdrawalTime) {
        
        uint amount = lockedTokenBalances[msg.sender];

        if (amount > 0) {
            
            lockedTokenBalances[msg.sender] = sub(lockedTokenBalances[msg.sender], amount);
            unlockedTokens[msg.sender].amountUnlocked = add(unlockedTokens[msg.sender].amountUnlocked, amount);
            unlockedTokens[msg.sender].withdrawalTime = now + 24 hours;
        }

        
        totalAmountUnlocked = unlockedTokens[msg.sender].amountUnlocked;
        withdrawalTime = unlockedTokens[msg.sender].withdrawalTime;
    }

    function withdrawUnlockedTokens() public {
        require(unlockedTokens[msg.sender].withdrawalTime < now, "The tokens cannot be withdrawn yet");
        balances[msg.sender] = add(balances[msg.sender], unlockedTokens[msg.sender].amountUnlocked);
        unlockedTokens[msg.sender].amountUnlocked = 0;
    }

    function min(uint a, uint b) public pure returns (uint) {
        if (a < b) {
            return a;
        } else {
            return b;
        }
    }
    
    
    
    
    
    function safeToAdd(uint a, uint b) public pure returns (bool) {
        return a + b >= a;
    }

    
    
    
    
    function safeToSub(uint a, uint b) public pure returns (bool) {
        return a >= b;
    }

    
    
    
    
    function add(uint a, uint b) public pure returns (uint) {
        require(safeToAdd(a, b), "It must be a safe adition");
        return a + b;
    }

    
    
    
    
    function sub(uint a, uint b) public pure returns (uint) {
        require(safeToSub(a, b), "It must be a safe substraction");
        return a - b;
    }
}


