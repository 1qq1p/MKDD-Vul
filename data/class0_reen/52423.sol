



library SafeMath {
    


    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        return a / b;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;   
    }
}

contract BasicToken {
    string private token_name;
    string private token_symbol;
    uint256 private token_decimals;

    uint256 private total_supply;
    uint256 private remaining_supply;

    mapping (address => uint256) private balance_of;
    mapping (address => mapping(address => uint256)) private allowance_of;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approve(address indexed target, address indexed spender, uint256 value);

    function BasicToken (
        string tokenName,
        string tokenSymbol,
        uint256 tokenDecimals,
        uint256 tokenSupply
    ) public {
        token_name = tokenName;
        token_symbol = tokenSymbol;
        token_decimals = tokenDecimals;
        total_supply = tokenSupply * (10 ** uint256(token_decimals));
        remaining_supply = total_supply;
    }

    function name() public view returns (string) {
        return token_name;
    }

    function symbol() public view returns (string) {
        return token_symbol;
    }

    function decimals() public view returns (uint256) {
        return token_decimals;
    }

    function totalSupply() public view returns (uint256) {
        return total_supply;
    }

    function remainingSupply() internal view returns (uint256) {
        return remaining_supply;
    }

    function balanceOf(
        address client_address
    ) public view returns (uint256) {
        return balance_of[client_address];
    }

    function setBalance(
        address client_address,
        uint256 value
    ) internal returns (bool) {
        require(client_address != address(0));
        balance_of[client_address] = value;
    }

    function allowance(
        address target_address,
        address spender_address
    ) public view returns (uint256) {
        return allowance_of[target_address][spender_address];
    }

    function approve(
        address spender_address,
        uint256 value
    ) public returns (bool) {
        require(value >= 0);
        require(msg.sender != address(0));
        require(spender_address != address(0));

        setApprove(msg.sender, spender_address, value);
        Approve(msg.sender, spender_address, value);
        return true;
    }
    
    function setApprove(
        address target_address,
        address spender_address,
        uint256 value
    ) internal returns (bool) {
        require(value >= 0);
        require(msg.sender != address(0));
        require(spender_address != address(0));

        allowance_of[target_address][spender_address] = value;
        return true;
    }

    function changeTokenName(
        string newTokenName
    ) internal returns (bool) {
        token_name = newTokenName;
        return true;
    }

    function changeTokenSymbol(
        string newTokenSymbol
    ) internal returns (bool) {
        token_symbol = newTokenSymbol;
        return true;
    }

    function changeTokenDecimals(
        uint256 newTokenDecimals
    ) internal returns (bool) {
        token_decimals = newTokenDecimals;
        return true;
    }

    function changeTotalSupply(
        uint256 newTotalSupply
    ) internal returns (bool) {
        total_supply = newTotalSupply;
        return true;
    }

    function changeRemainingSupply(
        uint256 newRemainingSupply
    ) internal returns (bool) {
        remaining_supply = newRemainingSupply;
        return true;
    }
}

