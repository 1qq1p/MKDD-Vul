pragma solidity 0.5.7;






contract LRC_v2 is StandardToken {
    using SafeMath for uint256;

    string     public name = "LoopringCoin V2";
    string     public symbol = "LRC";
    uint8      public decimals = 18;

    constructor() public {
        
        totalSupply_ = 1395076054523857892274603100;

        balances[msg.sender] = totalSupply_;
    }

    function batchTransfer(address[] calldata accounts, uint256[] calldata amounts)
        external
        returns (bool)
    {
        require(accounts.length == amounts.length);
        for (uint i = 0; i < accounts.length; i++) {
            require(transfer(accounts[i], amounts[i]), "transfer failed");
        }
        return true;
    }

    function () payable external {
        revert();
    }

}