interface IERC20 {
    function transfer(address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed holder, address indexed spender, uint256 value);
}

contract ReserveDollarEternalStorage {

    using SafeMath for uint256;



    

    address public owner;
    address public escapeHatch;

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event EscapeHatchTransferred(address indexed oldEscapeHatch, address indexed newEscapeHatch);

    
    constructor(address escapeHatchAddress) public {
        owner = msg.sender;
        escapeHatch = escapeHatchAddress;
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "onlyOwner");
        _;
    }

    
    function transferOwnership(address newOwner) external {
        require(msg.sender == owner || msg.sender == escapeHatch, "not authorized");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    
    function transferEscapeHatch(address newEscapeHatch) external {
        require(msg.sender == escapeHatch, "not authorized");
        emit EscapeHatchTransferred(escapeHatch, newEscapeHatch);
        escapeHatch = newEscapeHatch;
    }

    

    mapping(address => uint256) public balance;

    
    
    
    
    
    function addBalance(address key, uint256 value) external onlyOwner {
        balance[key] = balance[key].add(value);
    }

    
    function subBalance(address key, uint256 value) external onlyOwner {
        balance[key] = balance[key].sub(value);
    }

    
    function setBalance(address key, uint256 value) external onlyOwner {
        balance[key] = value;
    }



    

    mapping(address => mapping(address => uint256)) public allowed;

    
    function setAllowed(address from, address to, uint256 value) external onlyOwner {
        allowed[from][to] = value;
    }



    

    
    
    
    mapping(address => uint256) public frozenTime;

    
    function setFrozenTime(address who, uint256 time) external onlyOwner {
        frozenTime[who] = time;
    }
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