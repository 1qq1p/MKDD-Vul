pragma solidity ^0.5.3;





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

contract EtherCardDiscount is ERC20Pausable, Ownable, Batcher {
    string public name     = "EtherCard Discount Token";
    string public symbol   = "ether.card";
    uint8  public decimals = 0;

 
    constructor(address theOwner) public {
        batcher = 0xB6f9E6D9354b0c04E0556A168a8Af07b2439865E;
        transferOwnership(theOwner);
        _mint(theOwner,100);
    }


    function mint(address to, uint256 value) public onlyOwner returns (bool) {
        _mint(to, value);
        return true;
    }

    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    function sendBatchCS(address[] memory _recipients, uint[] memory _values) public ownerOrBatcher returns (bool) {
        return _sendBatchCS(_recipients, _values);
    }

}