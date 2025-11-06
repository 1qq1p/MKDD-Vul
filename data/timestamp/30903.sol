pragma solidity ^0.4.21;




contract IBancorConverterExtended is IBancorConverter, IOwned {
    function token() public view returns (ISmartToken) {}
    function quickBuyPath(uint256 _index) public view returns (IERC20Token) { _index; }
    function maxConversionFee() public view returns (uint32) {}
    function conversionFee() public view returns (uint32) {}
    function connectorTokenCount() public view returns (uint16);
    function reserveTokenCount() public view returns (uint16);
    function connectorTokens(uint256 _index) public view returns (IERC20Token) { _index; }
    function reserveTokens(uint256 _index) public view returns (IERC20Token) { _index; }
    function setConversionWhitelist(IWhitelist _whitelist) public view;
    function getQuickBuyPathLength() public view returns (uint256);
    function transferTokenOwnership(address _newOwner) public view;
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public view;
    function acceptTokenOwnership() public view;
    function transferManagement(address _newManager) public view;
    function acceptManagement() public;
    function setConversionFee(uint32 _conversionFee) public view;
    function setQuickBuyPath(IERC20Token[] _path) public view;
    function addConnector(IERC20Token _token, uint32 _weight, bool _enableVirtualBalance) public view;
    function getConnectorBalance(IERC20Token _connectorToken) public view returns (uint256);
    function getReserveBalance(IERC20Token _reserveToken) public view returns (uint256);
    function connectors(address _address) public view returns (
        uint256 virtualBalance, 
        uint32 weight, 
        bool isVirtualBalanceEnabled, 
        bool isPurchaseEnabled, 
        bool isSet
    );
    function reserves(address _address) public view returns (
        uint256 virtualBalance, 
        uint32 weight, 
        bool isVirtualBalanceEnabled, 
        bool isPurchaseEnabled, 
        bool isSet
    );
}



