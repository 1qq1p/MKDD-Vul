pragma solidity 0.4.25;
pragma experimental ABIEncoderV2;





contract ErrorReporter {
    function revertTx(string reason) public pure {
        revert(reason);
    }
}





