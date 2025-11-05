pragma solidity ^0.4.21;












contract RNG{
     uint256 secret = 0;
     
    
    
    modifier NoContract(){
        uint size;
        address addr = msg.sender;
        assembly { size := extcodesize(addr) }
        require(size == 0);
        _;
    }
    
    function RNG() public NoContract{
        secret = uint256(keccak256(block.coinbase));
    }
    
    function _giveRNG(uint256 modulo, uint256 secr) private view returns (uint256, uint256){
        uint256 seed1 = uint256(block.coinbase);
        uint256 seed3 = secr; 
        uint256 newsecr = (uint256(keccak256(seed1,seed3)));
        return (newsecr % modulo, newsecr);
    }
    

    function GiveRNG(uint256 max) internal NoContract returns (uint256){
        uint256 num;
        uint256 newsecret = secret;

        (num,newsecret) = _giveRNG(max, newsecret);
        secret=newsecret;
        return num; 
    }
    

}
