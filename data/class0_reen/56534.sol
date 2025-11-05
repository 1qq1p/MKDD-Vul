

















pragma solidity 0.5.7;
pragma experimental ABIEncoderV2;



contract PayableProxyForSoloMargin is
    OnlySolo,
    ReentrancyGuard
{
    

    bytes32 constant FILE = "PayableProxyForSoloMargin";

    

    WETH9 public WETH;

    

    constructor (
        address soloMargin,
        address payable weth
    )
        public
        OnlySolo(soloMargin)
    {
        WETH = WETH9(weth);
        WETH.approve(soloMargin, uint256(-1));
    }

    

    



    function ()
        external
        payable
    {
        require( 
            msg.sender == address(WETH),
            "Cannot receive ETH"
        );
    }

    function operate(
        Account.Info[] memory accounts,
        Actions.ActionArgs[] memory actions,
        address payable sendEthTo
    )
        public
        payable
        nonReentrant
    {
        WETH9 weth = WETH;

        
        if (msg.value != 0) {
            weth.deposit.value(msg.value)();
        }

        
        for (uint256 i = 0; i < actions.length; i++) {
            Actions.ActionArgs memory action = actions[i];

            
            address owner1 = accounts[action.accountId].owner;
            Require.that(
                owner1 == msg.sender,
                FILE,
                "Sender must be primary account",
                owner1
            );

            
            if (action.actionType == Actions.ActionType.Transfer) {
                address owner2 = accounts[action.otherAccountId].owner;
                Require.that(
                    owner2 == msg.sender,
                    FILE,
                    "Sender must be secondary account",
                    owner2
                );
            }
        }

        SOLO_MARGIN.operate(accounts, actions);

        
        uint256 remainingWeth = weth.balanceOf(address(this));
        if (remainingWeth != 0) {
            Require.that(
                sendEthTo != address(0),
                FILE,
                "Must set sendEthTo"
            );

            weth.withdraw(remainingWeth);
            sendEthTo.transfer(remainingWeth);
        }
    }
}