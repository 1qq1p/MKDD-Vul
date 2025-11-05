pragma solidity ^0.4.24;



contract MainBonus is BasicTime,BasicAuth,MainBase,MainCard
{
    uint constant BASERATIO = 10000;

    struct PlayerBonus
    {
        uint m_DrawedDay;
        uint16 m_DDPermanent;
        mapping(uint => uint16) m_DayStatic;
        mapping(uint => uint16) m_DayPermanent;
        mapping(uint => uint32[]) m_DayDynamic;
    }

    struct DayRatio
    {
        uint16 m_Static;
        uint16 m_Permanent;
        uint32[] m_DynamicCard;
        mapping(uint32 => uint) m_CardNum;
    }

    struct BonusData
    {
        uint m_RewardBonus;
        uint m_RecordDay;
        uint m_RecordBonus;
        uint m_RecordPR;
        mapping(uint => DayRatio) m_DayRatio;
        mapping(uint => uint) m_DayBonus;
        mapping(address => PlayerBonus) m_PlayerBonus;
    }

    BonusData g_Bonus;

    constructor() public
    {
        g_Bonus.m_RecordDay = GetDayCount(now);
    }

    function() external payable {}

    function NeedRefresh(uint dayNo) internal view returns(bool)
    {
        if (g_Bonus.m_RecordBonus == 0) return false;
        if (g_Bonus.m_RecordDay == dayNo) return false;
        return true;
    }

    function PlayerNeedRefresh(address acc, uint dayNo) internal view returns(bool)
    {
        if (g_Bonus.m_RecordBonus == 0) return false;
        PlayerBonus storage pb = g_Bonus.m_PlayerBonus[acc];
        if (pb.m_DrawedDay == dayNo) return false;
        return true;
    }

    function GetDynamicRatio(uint dayNo) internal view returns(uint tempRatio)
    {
        DayRatio storage dr = g_Bonus.m_DayRatio[dayNo];
        for (uint i=0; i<dr.m_DynamicCard.length; i++)
        {
            uint32 iCard = dr.m_DynamicCard[i];
            uint num = dr.m_CardNum[iCard];
            Card storage oCard = GetCard(iCard);
            tempRatio += num*oCard.m_DP*oCard.m_DPK/(oCard.m_DPK+num);
        }
    }

    function GenDayRatio(uint dayNo) internal view returns(uint iDR)
    {
        DayRatio storage dr = g_Bonus.m_DayRatio[dayNo];
        iDR += dr.m_Permanent;
        iDR += dr.m_Static;
        iDR += GetDynamicRatio(dayNo);
    }

    function GetDynamicCardNum(uint32 iCard, uint dayNo) internal view returns(uint num)
    {
        DayRatio storage dr = g_Bonus.m_DayRatio[dayNo];
        num = dr.m_CardNum[iCard];
    }

    function GetPlayerDynamicRatio(address acc, uint dayNo) internal view returns(uint tempRatio)
    {
        PlayerBonus storage pb = g_Bonus.m_PlayerBonus[acc];
        DayRatio storage dr = g_Bonus.m_DayRatio[dayNo];
        uint32[] storage cards = pb.m_DayDynamic[dayNo];
        for (uint idx=0; idx<cards.length; idx++)
        {
            uint32 iCard = cards[idx];
            uint num = dr.m_CardNum[iCard];
            Card storage oCard = GetCard(iCard);
            tempRatio += oCard.m_DP*oCard.m_DPK/(oCard.m_DPK+num);
        }
    }

    function GenPlayerRatio(address acc, uint dayNo) internal view returns(uint tempRatio)
    {
        PlayerBonus storage pb = g_Bonus.m_PlayerBonus[acc];
        tempRatio += pb.m_DayPermanent[dayNo];
        tempRatio += pb.m_DayStatic[dayNo];
        tempRatio += GetPlayerDynamicRatio(acc,dayNo);
    }

    function RefreshDayBonus() internal
    {
        uint todayNo = GetDayCount(now);
        if (!NeedRefresh(todayNo)) return;

        uint tempBonus = g_Bonus.m_RecordBonus;
        uint tempPR = g_Bonus.m_RecordPR;
        uint tempRatio;
        for (uint dayNo=g_Bonus.m_RecordDay; dayNo<todayNo; dayNo++)
        {
            tempRatio = tempPR+GenDayRatio(dayNo);
            if (tempRatio == 0) continue;
            DayRatio storage dr = g_Bonus.m_DayRatio[dayNo];
            tempPR += dr.m_Permanent;
            g_Bonus.m_DayBonus[dayNo] = tempBonus;
            tempBonus -= tempBonus*tempRatio/BASERATIO;
        }

        g_Bonus.m_RecordPR = tempPR;
        g_Bonus.m_RecordDay = todayNo;
        g_Bonus.m_RecordBonus = tempBonus;
    }

    function QueryPlayerBonus(address acc, uint todayNo) view internal returns(uint accBonus,uint16 accPR)
    {
        PlayerBonus storage pb = g_Bonus.m_PlayerBonus[acc];
        accPR = pb.m_DDPermanent;

        if (!PlayerNeedRefresh(acc, todayNo)) return;

        uint tempBonus = g_Bonus.m_RecordBonus;
        uint tempPR = g_Bonus.m_RecordPR;
        uint dayNo = pb.m_DrawedDay;
        if (dayNo == 0) return;
        for (; dayNo<todayNo; dayNo++)
        {
            uint tempRatio = tempPR+GenDayRatio(dayNo);
            if (tempRatio == 0) continue;

            uint accRatio = accPR+GenPlayerRatio(acc,dayNo);
            accPR += pb.m_DayPermanent[dayNo];

            DayRatio storage dr = g_Bonus.m_DayRatio[dayNo];
            if (dayNo >= g_Bonus.m_RecordDay) {
                tempPR += dr.m_Permanent;
                accBonus += tempBonus*accRatio/BASERATIO;
                tempBonus -= tempBonus*tempRatio/BASERATIO;
            }
            else {
                if (accRatio == 0) continue;
                accBonus += g_Bonus.m_DayBonus[dayNo]*accRatio/BASERATIO;
            }
        }
    }

    function GetDynamicCardAmount(uint32 iCard, uint timestamp) external view returns(uint num)
    {
        num = GetDynamicCardNum(iCard, GetDayCount(timestamp));
    }

    function AddDynamicProfit(address acc, uint32 iCard, uint duration) internal
    {
        RefreshDayBonus();
        uint todayNo = GetDayCount(now);
        PlayerBonus storage pb = g_Bonus.m_PlayerBonus[acc];
        if (pb.m_DrawedDay == 0) pb.m_DrawedDay = todayNo;
        for (uint dayNo=todayNo; dayNo<todayNo+duration; dayNo++)
        {
            pb.m_DayDynamic[dayNo].push(iCard);
            DayRatio storage dr= g_Bonus.m_DayRatio[dayNo];
            if (dr.m_CardNum[iCard] == 0) {
                dr.m_DynamicCard.push(iCard);
            }
            dr.m_CardNum[iCard]++;
        }
    }

    function AddStaticProfit(address acc,uint16 ratio,uint duration) internal
    {
        RefreshDayBonus();
        uint todayNo = GetDayCount(now);
        PlayerBonus storage pb = g_Bonus.m_PlayerBonus[acc];
        if (pb.m_DrawedDay == 0) pb.m_DrawedDay = todayNo;
        if (duration == 0) {
            pb.m_DayPermanent[todayNo] += ratio;
            g_Bonus.m_DayRatio[todayNo].m_Permanent += ratio;
        }
        else {
            for (uint dayNo=todayNo; dayNo<todayNo+duration; dayNo++)
            {
                pb.m_DayStatic[dayNo] += ratio;
                g_Bonus.m_DayRatio[dayNo].m_Static += ratio;
            }
        }
    }

    function ImmediateProfit(address acc, uint ratio) internal
    {
        RefreshDayBonus();
        uint bonus = ratio*g_Bonus.m_RecordBonus/BASERATIO;
        g_Bonus.m_RecordBonus -= bonus;
        g_Bonus.m_RewardBonus -= bonus;
        if (bonus == 0) return
        acc.transfer(bonus);
    }


    function ProfitByCard(address acc, uint32 iCard) internal
    {
        Card storage oCard = GetCard(iCard);
        if (oCard.m_IP > 0) {
            ImmediateProfit(acc,oCard.m_IP);
        }
        else if (oCard.m_SP > 0) {
            AddStaticProfit(acc,oCard.m_SP,oCard.m_Duration);
        }
        else {
            AddDynamicProfit(acc,iCard,oCard.m_Duration);
        }
    }

    function QueryBonus() external view returns(uint)
    {
        uint todayNo = GetDayCount(now);
        if (!NeedRefresh(todayNo)) return g_Bonus.m_RecordBonus;

        uint tempBonus = g_Bonus.m_RecordBonus;
        uint tempPR = g_Bonus.m_RecordPR;
        uint tempRatio;
        for (uint dayNo=g_Bonus.m_RecordDay; dayNo<todayNo; dayNo++)
        {
            tempRatio = tempPR+GenDayRatio(dayNo);
            if (tempRatio == 0) continue;
            DayRatio storage dr = g_Bonus.m_DayRatio[dayNo];
            tempPR += dr.m_Permanent;
            tempBonus -= tempBonus*tempRatio/BASERATIO;
        }
        return tempBonus;
    }

    function QueryMyBonus(address acc) external view returns(uint bonus)
    {
        (bonus,) = QueryPlayerBonus(acc, GetDayCount(now));
    }

    function AddBonus(uint bonus) external AuthAble
    {
        RefreshDayBonus();
        g_Bonus.m_RewardBonus += bonus;
        g_Bonus.m_RecordBonus += bonus;
    }

    function Withdraw(address acc) external
    {
        RefreshDayBonus();
        PlayerBonus storage pb = g_Bonus.m_PlayerBonus[acc];
        uint bonus;
        uint todayNo = GetDayCount(now);
        (bonus, pb.m_DDPermanent) = QueryPlayerBonus(acc, todayNo);
        require(bonus > 0);
        pb.m_DrawedDay = todayNo;
        acc.transfer(bonus);
        g_Bonus.m_RewardBonus -= bonus;
    }

    function MasterWithdraw() external
    {
        uint bonus = address(this).balance-g_Bonus.m_RewardBonus;
        require(bonus > 0);
        master.transfer(bonus);
    }


}



