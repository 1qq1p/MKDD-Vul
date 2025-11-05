pragma solidity ^0.4.25;







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

    


    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = ((add(x, 1)) / 2);
        y = x;
        while (z < y) {
            y = z;
            z = ((add((x / z), z)) / 2);
        }
    }
    
    


    function sq(uint256 x) internal pure returns (uint256) {
        return (mul(x, x));
    }
    
    


    function pwr(uint256 x, uint256 y) internal pure returns (uint256)
    {
        if (x == 0) {
            return (0);
        }
        else if (y == 0) {
            return 1;
        }
        else {
            uint256 z = x;
            for (uint256 i = 1; i < y; i++) {
                z = mul(z, x);
            }
            return z;
        }
    }
}




library Address {
    






    function isContract(address account) internal view returns (bool) {
        uint256 size;
        
        
        
        
        
        
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}






contract CommonConfig
{
    uint32 constant public SECONDS_PER_DAY = 5 * 60; 

    uint32 constant public BASE_RATIO = 10000;
}





interface IERC165 {
    





    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}





