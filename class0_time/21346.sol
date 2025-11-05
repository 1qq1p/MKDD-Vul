pragma solidity ^0.4.24;

interface ERC20Token {
    function name() public view returns (string);
    function symbol() public view returns (string);
    function decimals() public view returns (uint8);
    function totalSupply() public view returns (uint256);
    function balanceOf(address owner) public view returns (uint256);
    function transfer(address to, uint256 amount) public returns (bool);
    function transferFrom(address from, address to, uint256 amount) public returns (bool);
    function approve(address spender, uint256 amount) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);

    
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}

interface ERC777Token {
    function name() public view returns (string);
    function symbol() public view returns (string);
    function totalSupply() public view returns (uint256);
    function balanceOf(address owner) public view returns (uint256);
    function granularity() public view returns (uint256);

    function defaultOperators() public view returns (address[]);
    function isOperatorFor(address operator, address tokenHolder) public view returns (bool);
    
    

    function send(address to, uint256 amount, bytes data) public;
    function operatorSend(address from, address to, uint256 amount, bytes data, bytes operatorData) public;

    function burn(uint256 amount, bytes data) public;
    function operatorBurn(address from, uint256 amount, bytes data, bytes operatorData) public;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    ); 
    event Minted(address indexed operator, address indexed to, uint256 amount, bytes operatorData);
    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);
    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}

interface ERC777TokensRecipient {
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes data,
        bytes operatorData
    ) public;
}


interface ERC777TokensSender {
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint amount,
        bytes userData,
        bytes operatorData
    ) public;
}


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

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    


    function add(Role storage role, address account) internal {
        require(account != address(0), "Address cannot be zero");
        require(!has(role, account), "Role already exist");

        role.bearer[account] = true;
    }

    


    function remove(Role storage role, address account) internal {
        require(account != address(0), "Address cannot be zero");
        require(has(role, account), "Role is nort exist");

        role.bearer[account] = false;
    }

    



    function has(Role storage role, address account)
        internal
        view
        returns (bool)
    {
        require(account != address(0), "Address cannot be zero");
        return role.bearer[account];
    }
}


contract Transferable is Ownable {
    
    mapping(address => bool) private banned;
    
    modifier isTransferable() {
        require(!banned[msg.sender], "Account is frozen");
        _;
    }
    
    function freezeAccount(address account) public onlyOwner {
        banned[account] = true;
    }   
    
    function unfreezeAccount(address account) public onlyOwner {
        banned[account] = false;
    }

    function isAccountFrozen(address account) public view returns(bool) {
        return banned[account];
    }
    
} 
