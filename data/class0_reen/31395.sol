pragma solidity 0.4.25;
pragma experimental ABIEncoderV2;





contract TokenStoreSelectorProvider is SelectorProvider {
    function getSelector(bytes4 genericSelector) public pure returns (bytes4) {
        if (genericSelector == getAmountToGive) {
            return bytes4(keccak256("getAmountToGive((address,uint256,address,uint256,uint256,uint256,address,uint8,bytes32,bytes32))"));
        } else if (genericSelector == staticExchangeChecks) {
            return bytes4(keccak256("staticExchangeChecks((address,uint256,address,uint256,uint256,uint256,address,uint8,bytes32,bytes32))"));
        } else if (genericSelector == performBuyOrder) {
            return bytes4(keccak256("performBuyOrder((address,uint256,address,uint256,uint256,uint256,address,uint8,bytes32,bytes32),uint256)"));
        } else if (genericSelector == performSellOrder) {
            return bytes4(keccak256("performSellOrder((address,uint256,address,uint256,uint256,uint256,address,uint8,bytes32,bytes32),uint256)"));
        } else {
            return bytes4(0x0);
        }
    }
}

