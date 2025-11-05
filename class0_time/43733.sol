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















contract XCOYNZ is ERC20Burnable, ERC20Detailed {
    string public constant NAME = "XCOYNZ Token"; 
    string public constant SYMBOL = "XCZ"; 
    address public constant tokenOwner = 0xbA643A286c43Ec70a02bA464653AF512BE4BB570;
    uint8 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 1250000000 * (10 ** uint256(DECIMALS));
    

    


    constructor () public ERC20Detailed(NAME, SYMBOL, DECIMALS) {
        _mint(tokenOwner, INITIAL_SUPPLY);
    }


    




    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(this));
        if (msg.sender == tokenOwner)   
            if (uint64(now) <  1580515200)
                require((balanceOf(tokenOwner) - value) >= 377326483460000000000000000); 
            if (uint64(now) <  1596240000)
                require((balanceOf(tokenOwner) - value) >= 289145890080000000000000000); 
            if (uint64(now) <  1627776000)
                require((balanceOf(tokenOwner) - value) >= 165000000000000000000000000); 
            if (uint64(now) <  1659312000)
                require((balanceOf(tokenOwner) - value) >=  65625000000000000000000000); 


        _transfer(msg.sender, to, value);
        return true;
    }
    
     







    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(this));
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        if (from == tokenOwner)   
            if (uint64(now) <  1580515200)
                require((balanceOf(tokenOwner) - value) >= 377326483460000000000000000); 
            if (uint64(now) <  1596240000)
                require((balanceOf(tokenOwner) - value) >= 289145890080000000000000000); 
            if (uint64(now) <  1627776000)
                require((balanceOf(tokenOwner) - value) >= 165000000000000000000000000); 
            if (uint64(now) <  1659312000)
                require((balanceOf(tokenOwner) - value) >=  65625000000000000000000000); 
        
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }
    
    



    function burn(uint256 value) public {
        require(msg.sender == tokenOwner);
        _burn(msg.sender, value);
    }

}