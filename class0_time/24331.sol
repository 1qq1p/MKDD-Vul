pragma solidity 0.4.24;
 













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

interface Token {
    
    
    
    
    function mintToken(address to, uint amount) external returns (bool success);  

    
    
    function balanceOf(address _owner) public view returns (uint256 balance);

    
    
    
    
    function transfer(address _to, uint256 _value) public returns (bool success);    
}

contract MintableSale {
    
    
    
    
    
    
    function createMintableSale(address vestingAddress, uint256 rate, uint256 fundingGoalInEthers, uint durationInMinutes) public returns (bool success);
}
