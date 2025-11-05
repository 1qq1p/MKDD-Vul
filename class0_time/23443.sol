pragma solidity 0.4.24;






contract Derivative is DerivativeInterface, ComponentContainer, PausableToken {

    ERC20Extended internal constant ETH = ERC20Extended(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    ComponentListInterface internal componentList;
    string public constant MARKET = "MarketProvider";
    string public constant EXCHANGE = "ExchangeProvider";
    string public constant WITHDRAW = "WithdrawProvider";
    string public constant RISK = "RiskProvider";
    string public constant WHITELIST = "WhitelistProvider";
    string public constant FEE = "FeeProvider";
    string public constant REIMBURSABLE = "Reimbursable";
    string public constant REBALANCE = "RebalanceProvider";

    function initialize (address _componentList) internal {
        require(_componentList != 0x0);
        componentList = ComponentListInterface(_componentList);
    }

    function updateComponent(string _name) public onlyOwner returns (address) {
        
        if (super.getComponentByName(_name) == componentList.getLatestComponent(_name)) {
            return super.getComponentByName(_name);
        }

        
        require(super.setComponent(_name, componentList.getLatestComponent(_name)));
        
        if (keccak256(abi.encodePacked(_name)) != keccak256(abi.encodePacked(MARKET))) {
            approveComponent(_name);
        }

        
        return componentList.getLatestComponent(_name);
    }



    function approveComponent(string _name) internal {
        address componentAddress = getComponentByName(_name);
        ERC20NoReturn(FeeChargerInterface(componentAddress).MOT()).approve(componentAddress, 0);
        ERC20NoReturn(FeeChargerInterface(componentAddress).MOT()).approve(componentAddress, 2 ** 256 - 1);
    }

    function () public payable {

    }
}
