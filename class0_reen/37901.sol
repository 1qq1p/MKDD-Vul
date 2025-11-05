
pragma solidity ^0.4.18;







contract UbiatarPlayVault {
    using SafeMath for uint256;
    using SafeERC20 for UacToken;

    uint256[6] public vesting_offsets = [
        90 days,
        180 days,
        270 days,
        360 days,
        540 days,
        720 days
    ];

    uint256[6] public vesting_amounts = [
        2e6 * 1e18,
        4e6 * 1e18,
        6e6 * 1e18,
        8e6 * 1e18,
        10e6 * 1e18,
        20.5e6 * 1e18
    ];

    address public ubiatarPlayWallet;
    UacToken public token;
    uint256 public start;
    uint256 public released;

    





    function UbiatarPlayVault(
        address _ubiatarPlayWallet,
        address _token,
        uint256 _start
    )
        public
    {
        ubiatarPlayWallet = _ubiatarPlayWallet;
        token = UacToken(_token);
        start = _start;
    }

    


    function release() public {
        uint256 unreleased = releasableAmount();
        require(unreleased > 0);

        released = released.add(unreleased);

        token.safeTransfer(ubiatarPlayWallet, unreleased);
    }

    


    function releasableAmount() public view returns (uint256) {
        return vestedAmount().sub(released);
    }

    


    function vestedAmount() public view returns (uint256) {
        uint256 vested = 0;

        for (uint256 i = 0; i < vesting_offsets.length; i = i.add(1)) {
            if (block.timestamp > start.add(vesting_offsets[i])) {
                vested = vested.add(vesting_amounts[i]);
            }
        }

        return vested;
    }
}











pragma solidity ^0.4.17;






