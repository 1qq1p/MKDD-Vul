pragma solidity ^0.4.24;



contract Child is Base {

    Main g_Main;

    constructor(Main main) public
    {
        require(main != address(0));
        g_Main = main;
        g_Main.SetAuth(this);
    }

    function kill() external MasterAble
    {
        g_Main.ClearAuth(this);
        selfdestruct(creator);
    }

    function AddBonus(uint percent) internal
    {
        address(g_Main).transfer(msg.value);
        g_Main.AddBonus(msg.value * percent / 100);
    }

    function GenRandom(uint seed,uint base) internal view returns(uint,uint)
    {
        uint r = uint(keccak256(abi.encodePacked(msg.sender,seed,now)));
        if (base != 0) r %= base;
        return (r,seed+1);
    }

}



