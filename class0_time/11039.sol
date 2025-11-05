pragma solidity ^0.4.24;

interface CitizenInterface {
    
    function getUsername(address _address) public view returns (string);
    function getRef(address _address) public view returns (address);
}

interface F2mInterface {
    function pushDividends() public payable;
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

contract Helper {
    uint256 constant public GAS_COST = 0.002 ether;
    uint256 constant public MAX_BLOCK_DISTANCE = 254;
    uint256 constant public ZOOM = 1000000000;

    function getKeyBlockNr(uint256 _estKeyBlockNr)
        public
        view
        returns(uint256)
    {
        require(block.number > _estKeyBlockNr, "blockHash not avaiable");
        uint256 jump = (block.number - _estKeyBlockNr) / MAX_BLOCK_DISTANCE * MAX_BLOCK_DISTANCE;
        return _estKeyBlockNr + jump;
    }

    function getSeed(uint256 _keyBlockNr)
        public
        view
        returns (uint256)
    {
        
        if (block.number <= _keyBlockNr) return block.number;
        return uint256(blockhash(_keyBlockNr));
    }

    function getWinTeam(
        uint256 _seed,
        uint256 _trueAmount,
        uint256 _falseAmount
    )
        public
        pure
        returns (bool)
    {
        uint256 _sum = _trueAmount + _falseAmount;
        if (_sum == 0) return true;
        return (_seed % _sum) < _trueAmount;
    }

    function getWinningPerWei(
        uint256 _winTeam,
        uint256 _lostTeam
    )
        public
        pure
        returns (uint256)
    {
        return _lostTeam * ZOOM / _winTeam;
    }

    function getMin(
        uint256 a,
        uint256 b
    )
        public
        pure
        returns (uint256)
    {
        return a < b ? a : b;
    }
}
