pragma solidity ^0.4.24;

contract Cosigner {
    uint256 public constant VERSION = 2;
    
    


    function url() external view returns (string);
    
    




    function cost(address engine, uint256 index, bytes data, bytes oracleData) external view returns (uint256);
    
    






    function requestCosign(Engine engine, uint256 index, bytes data, bytes oracleData) public returns (bool);
    
    





    function claim(address engine, uint256 index, bytes oracleData) external returns (bool);
}

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x + y;
        require((z >= x) && (z >= y));
        return z;
    }

    function sub(uint256 x, uint256 y) internal pure returns(uint256) {
        require(x >= y);
        uint256 z = x - y;
        return z;
    }

    function mult(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x * y;
        require((x == 0)||(z/x == y));
        return z;
    }
}

