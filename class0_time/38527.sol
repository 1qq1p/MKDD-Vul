pragma solidity ^0.4.23;

pragma solidity ^0.4.23;

pragma solidity ^0.4.23;

pragma solidity ^0.4.23;


pragma solidity ^0.4.23;







contract CutiePluginBaseFee is CutiePluginBase
{
    
    
    uint16 public ownerFee;

    
    
    
    
    
    
    function setup(address _coreAddress, address _pluginsContract, uint16 _fee) external onlyOwner {
        require(_fee <= 10000);
        ownerFee = _fee;

        super.setup(_coreAddress, _pluginsContract);
    }

    
    
    function setFee(uint16 _fee) external onlyOwner
    {
        require(_fee <= 10000);

        ownerFee = _fee;
    }

    
    
    function _computeFee(uint128 _price) internal view returns (uint128) {
        
        
        
        
        
        return _price * ownerFee / 10000;
    }
}



