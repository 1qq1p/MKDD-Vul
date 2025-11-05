








pragma solidity ^0.4.20;



interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}



contract Random {
    uint256 _seed;

    function _rand() internal returns (uint256) {
        _seed = uint256(keccak256(_seed, block.blockhash(block.number - 1), block.coinbase, block.difficulty));
        return _seed;
    }

    function _randBySeed(uint256 _outSeed) internal view returns (uint256) {
        return uint256(keccak256(_outSeed, block.blockhash(block.number - 1), block.coinbase, block.difficulty));
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
