pragma solidity 0.4.21;

interface TokenToken {
    function pause() public;
    function unpause() public;
    function mint(address _to, uint256 _amount) public returns (bool);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function getTotalSupply() public view returns(uint);
    function finishMinting() public returns (bool);
}








contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    



    function Ownable() public {
        owner = msg.sender;
    }


    


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    



    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}







library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        uint256 c = a / b;
        
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}






