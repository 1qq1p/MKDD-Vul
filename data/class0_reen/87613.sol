

pragma solidity ^0.5.2;





interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.5.2;





library SafeMath {
    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}



pragma solidity ^0.5.2;















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



pragma solidity ^0.5.2;




library Address {
    






    function isContract(address account) internal view returns (bool) {
        uint256 size;
        
        
        
        
        
        
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

















pragma solidity ^0.5.2;



library SafeERC20 {
    using Address for address;

    bytes4 constant private TRANSFER_SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));
    bytes4 constant private TRANSFERFROM_SELECTOR = bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));
    bytes4 constant private APPROVE_SELECTOR = bytes4(keccak256(bytes("approve(address,uint256)")));

    function safeTransfer(address _erc20Addr, address _to, uint256 _value) internal {

        
        require(_erc20Addr.isContract());

        (bool success, bytes memory returnValue) =
        
        _erc20Addr.call(abi.encodeWithSelector(TRANSFER_SELECTOR, _to, _value));
        
        require(success);
        
        require(returnValue.length == 0 || (returnValue.length == 32 && (returnValue[31] != 0)));
    }

    function safeTransferFrom(address _erc20Addr, address _from, address _to, uint256 _value) internal {

        
        require(_erc20Addr.isContract());

        (bool success, bytes memory returnValue) =
        
        _erc20Addr.call(abi.encodeWithSelector(TRANSFERFROM_SELECTOR, _from, _to, _value));
        
        require(success);
        
        require(returnValue.length == 0 || (returnValue.length == 32 && (returnValue[31] != 0)));
    }

    function safeApprove(address _erc20Addr, address _spender, uint256 _value) internal {

        
        require(_erc20Addr.isContract());

        
        
        require((_value == 0) || (IERC20(_erc20Addr).allowance(msg.sender, _spender) == 0));

        (bool success, bytes memory returnValue) =
        
        _erc20Addr.call(abi.encodeWithSelector(APPROVE_SELECTOR, _spender, _value));
        
        require(success);
        
        require(returnValue.length == 0 || (returnValue.length == 32 && (returnValue[31] != 0)));
    }
}



pragma solidity ^0.5.0;







