pragma solidity ^0.4.24;



contract Home is Child,BasicTime
{
    uint32 constant SGININ_REWARD_TEMPSTUFF = 23001;
    uint constant SGININ_REWARD_FREEDAY = 10;
    uint32 constant SGININ_REWARD_STUFF = 21000;
    uint constant SGININ_REWARD_NUM = 300;

    mapping(address => uint) g_SignInDay;


    constructor(Main main) public Child(main) {}

    function CanSignIn() internal view returns(bool bCanSignIn, uint expire, uint dayNo)
    {
        dayNo = GetDayCount(now);
        expire = g_Main.GetTempStuffExpire(msg.sender,SGININ_REWARD_TEMPSTUFF);
        if (g_SignInDay[msg.sender] >= dayNo) return;
        if (expire>0 && expire<now) return;
        bCanSignIn = true;
    }

    function GetDayReward() external
    {
        (bool bCanSignIn, uint expire, uint todayNo) = CanSignIn();
        require(bCanSignIn);
        g_SignInDay[msg.sender] = todayNo;
        if (expire == 0) {
            
            g_Main.GainTempStuff(msg.sender, SGININ_REWARD_TEMPSTUFF, SGININ_REWARD_FREEDAY);
        }
        g_Main.GainStuff(msg.sender, SGININ_REWARD_STUFF, SGININ_REWARD_NUM);
    }

    function Withdraw() external
    {
        g_Main.Withdraw(msg.sender);
    }

    function GetPlayerInfo() external view returns(
        bool bCanSignIn,
        uint allBonus,
        uint myBonus,
        uint32[] stuffIdxList,
        uint[] stuffNumList,
        uint32[] tempStuffList,
        uint[] tempStuffTime
    )
    {
        (bCanSignIn,,) = CanSignIn();
        allBonus = g_Main.QueryBonus();
        myBonus = g_Main.QueryMyBonus(msg.sender);
        (stuffIdxList,stuffNumList) = g_Main.GetStuffList(msg.sender);
        (tempStuffList,tempStuffTime) = g_Main.GetTempStuffList(msg.sender);
    }

    function Donate() payable external
    {
        require(msg.value > 0);
        AddBonus(100);
    }

}