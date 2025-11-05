pragma solidity ^0.4.24;



contract MainBag is BasicTime,BasicAuth,MainChip,MainCard
{
    using ItemList for ItemList.Data;

    struct Bag
    {
        ItemList.Data m_Stuff;
        ItemList.Data m_TempStuff;
        ItemList.Data m_Chips;
        ItemList.Data m_TempCards; 
        ItemList.Data m_PermCards; 
    }

    mapping(address => Bag) g_BagList;

    function GainStuff(address acc, uint32 iStuff, uint iNum) external AuthAble OwnerAble(acc)
    {
        Bag storage obj = g_BagList[acc];
        obj.m_Stuff.add(iStuff,iNum);
    }

    function CostStuff(address acc, uint32 iStuff, uint iNum) external AuthAble OwnerAble(acc)
    {
        Bag storage obj = g_BagList[acc];
        obj.m_Stuff.sub(iStuff,iNum);
    }

    function GetStuffNum(address acc, uint32 iStuff) view external returns(uint)
    {
        Bag storage obj = g_BagList[acc];
        return obj.m_Stuff.get(iStuff);
    }

    function GetStuffList(address acc) external view returns(uint32[],uint[])
    {
        Bag storage obj = g_BagList[acc];
        return obj.m_Stuff.list();
    }

    function GainTempStuff(address acc, uint32 iStuff, uint dayCnt) external AuthAble OwnerAble(acc)
    {
        Bag storage obj = g_BagList[acc];
        require(obj.m_TempStuff.get(iStuff) <= now);
        obj.m_TempStuff.set(iStuff,now+dayCnt*DAY_SECONDS);
    }

    function GetTempStuffExpire(address acc, uint32 iStuff) external view returns(uint expire)
    {
        Bag storage obj = g_BagList[acc];
        expire = obj.m_TempStuff.get(iStuff);
    }

    function GetTempStuffList(address acc) external view returns(uint32[],uint[])
    {
        Bag storage obj = g_BagList[acc];
        return obj.m_TempStuff.list();
    }

    function GainChip(address acc, uint32 iChip,bool bGenerated) external AuthAble OwnerAble(acc)
    {
        if (!bGenerated) {
            require(CanObtainChip(iChip));
            ObtainChip(iChip);
        }
        Bag storage obj = g_BagList[acc];
        obj.m_Chips.add(iChip,1);
    }

    function CostChip(address acc, uint32 iChip) external AuthAble OwnerAble(acc)
    {
        Bag storage obj = g_BagList[acc];
        obj.m_Chips.sub(iChip,1);
        CostChip(iChip);
    }

    function GetChipNum(address acc, uint32 iChip) external view returns(uint)
    {
        Bag storage obj = g_BagList[acc];
        return obj.m_Chips.get(iChip);
    }

    function GetChipList(address acc) external view returns(uint32[],uint[])
    {
        Bag storage obj = g_BagList[acc];
        return obj.m_Chips.list();
    }

    function GainCard2(address acc, uint32 iCard) internal
    {
        Card storage oCard = GetCard(iCard);
        if (oCard.m_IP > 0) return;
        uint i;
        uint32 iChip;
        Bag storage obj = g_BagList[acc];
        if (oCard.m_Duration > 0) {
            
            uint expireTime = GetExpireTime(now,oCard.m_Duration);
            for (i=0; i<oCard.m_Parts.length; i++)
            {
                iChip = oCard.m_Parts[i];
                AddChipTempTime(iChip,expireTime);
            }
            obj.m_TempCards.set(iCard,expireTime);
        }
        else {
            
            for (i=0; i<oCard.m_Parts.length; i++)
            {
                iChip = oCard.m_Parts[i];
                ObtainChip(iChip);
            }
            obj.m_PermCards.set(iCard,1);
        }
    }

    function HasCard(address acc, uint32 iCard) public view returns(bool)
    {
        Bag storage obj = g_BagList[acc];
        if (obj.m_TempCards.get(iCard) > now) return true;
        if (obj.m_PermCards.has(iCard)) return true;
        return false;
    }

    function GetCardList(address acc) external view returns(uint32[] tempCards, uint[] cardsTime, uint32[] permCards)
    {
        Bag storage obj = g_BagList[acc];
        (tempCards,cardsTime) = obj.m_TempCards.list();
        permCards = obj.m_PermCards.keys();
    }


}



