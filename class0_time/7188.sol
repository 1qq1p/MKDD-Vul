pragma solidity 0.4.15;


contract IsContract {

    
    
    

    function isContract(address addr)
        internal
        constant
        returns (bool)
    {
        uint256 size;
        
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}
