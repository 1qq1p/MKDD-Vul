pragma solidity 0.5.8;

interface IERC20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
}

contract Invoice {
    address public owner;

    


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(address _owner) public {
        owner = _owner;
    }
    
    function reclaimToken(IERC20 _token) external onlyOwner {
        uint256 balance = _token.balanceOf(address(this));
        _token.transfer(owner, balance);
    }
}
