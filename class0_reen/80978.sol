pragma solidity 0.4.24;






contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    



    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    


    function owner() public view returns (address) {
        return _owner;
    }

    


    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    


    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    





    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    



    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    



    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}





library SafeMath {
    int256 constant private INT256_MIN = -2**255;

    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    


    function mul(int256 a, int256 b) internal pure returns (int256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); 

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    


    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); 
        require(!(b == -1 && a == INT256_MIN)); 

        int256 c = a / b;

        return c;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    


    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    


    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}







