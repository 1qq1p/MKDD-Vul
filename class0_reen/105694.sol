pragma solidity ^0.4.15;

contract GoolaStop is Owned{

    bool public stopped = false;

    modifier stoppable {
        assert (!stopped);
        _;
    }
    function stop() public ownerOnly{
        stopped = true;
    }
    function start() public ownerOnly{
        stopped = false;
    }

}

