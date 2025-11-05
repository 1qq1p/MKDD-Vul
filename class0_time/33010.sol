pragma solidity ^0.4.18; 




contract AgriChainMasterContract   is AgriChainContract    
{  
    address public  AgriChainContext;  
    address public  AgriChainCultivation;  
    address public  AgriChainProduction;   
    address public  AgriChainDistribution; 
    address public  AgriChainDocuments; 

    function   AgriChainMasterContract() public
    { 
       AgriChainContext=address(this);
       AgriChainCultivation=address(this);
       AgriChainProduction=address(this);
       AgriChainDistribution=address(this);
       
    }
    function setAgriChainProduction(address _AgriChain)  onlyBy(creator) onlyIfNotSealed()
    {
         AgriChainProduction = _AgriChain;
         EventChangedAddress(this,'AgriChainProduction',_AgriChain);
    }
    function setAgriChainCultivation(address _AgriChain)  onlyBy(creator) onlyIfNotSealed()
    {
         AgriChainCultivation = _AgriChain;
         EventChangedAddress(this,'AgriChainCultivation',_AgriChain);
    }
    function setAgriChainDistribution(address _AgriChain)  onlyBy(creator) onlyIfNotSealed()
    {
         AgriChainDistribution = _AgriChain;
         EventChangedAddress(this,'AgriChainDistribution',_AgriChain);
    }
    
    function setAgriChainDocuments(address _AgriChain)  onlyBy(creator) onlyIfNotSealed()
    {
         AgriChainDocuments = _AgriChain;
         EventChangedAddress(this,'AgriChainDocuments',_AgriChain);
    }
    function setAgriChainContext(address _AgriChain)  onlyBy(creator) onlyIfNotSealed()
    {
         AgriChainContext = _AgriChain;
         EventChangedAddress(this,'AgriChainContext',_AgriChain);
    }
    
}



