pragma solidity >=0.5.0 <0.6.0;





library SafeMathUint256 {
    


    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath: Multiplier exception");
        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b; 
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: Subtraction exception");
        return a - b;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a, "SafeMath: Addition exception");
        return c;
    }

    



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: Modulo exception");
        return a % b;
    }

}





library SafeMathUint8 {
    


    function mul(uint8 a, uint8 b) internal pure returns (uint8 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath: Multiplier exception");
        return c;
    }

    


    function div(uint8 a, uint8 b) internal pure returns (uint8) {
        return a / b; 
    }

    


    function sub(uint8 a, uint8 b) internal pure returns (uint8) {
        require(b <= a, "SafeMath: Subtraction exception");
        return a - b;
    }

    


    function add(uint8 a, uint8 b) internal pure returns (uint8 c) {
        c = a + b;
        require(c >= a, "SafeMath: Addition exception");
        return c;
    }

    



    function mod(uint8 a, uint8 b) internal pure returns (uint8) {
        require(b != 0, "SafeMath: Modulo exception");
        return a % b;
    }

}


contract ApprovalReceiver {
    function receiveApproval(address _from, uint256 _value, address _tokenContract, bytes memory _extraData) public;
}
