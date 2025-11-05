pragma solidity ^0.4.23;

pragma solidity ^0.4.23;

pragma solidity ^0.4.23;


pragma solidity ^0.4.23;







contract GenerationDecreaseEffect is CutiePluginBase
{
    function run(
        uint40,
        uint256,
        address
    ) 
        public
        payable
        onlyPlugins
    {
        revert();
    }

    function runSigned(
        uint40 _cutieId,
        uint256 _parameter,
        address 
    ) 
        external
        onlyPlugins
        whenNotPaused
        payable
    {
        uint16 generation = coreContract.getGeneration(_cutieId);
        require(generation > 0);
        if (generation > _parameter)
        {
            generation -= uint16(_parameter);
        }
        else
        {
            generation = 0;
        }
        coreContract.changeGeneration(_cutieId, generation);
    }
}