












pragma solidity ^0.4.24;






contract KingOfEthEthExchangeReferencer is GodMode {
    
    address public ethExchangeContract;

    
    modifier onlyEthExchangeContract()
    {
        require(ethExchangeContract == msg.sender);
        _;
    }

    
    
    function godSetEthExchangeContract(address _ethExchangeContract)
        public
        onlyGod
    {
        ethExchangeContract = _ethExchangeContract;
    }
}














pragma solidity ^0.4.24;





