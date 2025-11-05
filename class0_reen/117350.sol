pragma solidity ^0.4.24;



contract MainChip is BasicAuth
{
    using IndexList for uint32[];

    struct Chip
    {
        uint8 m_Level;
        uint8 m_LimitNum;
        uint8 m_Part;
        uint32 m_Index;
        uint256 m_UsedNum;
    }

    struct PartManager
    {
        uint32[] m_IndexList;   
        uint32[] m_UnableList;  
    }

    struct ChipLib
    {
        uint32[] m_List;
        mapping(uint32 => Chip) m_Lib;
        mapping(uint32 => uint[]) m_TempList;
        mapping(uint8 => mapping(uint => PartManager)) m_PartMap;
    }

    ChipLib g_ChipLib;

    function AddNewChip(uint32 iChip, uint8 lv, uint8 limit, uint8 part) internal
    {
        require(!ChipExists(iChip));
        g_ChipLib.m_List.push(iChip);
        g_ChipLib.m_Lib[iChip] = Chip({
            m_Index       : iChip,
            m_Level       : lv,
            m_LimitNum    : limit,
            m_Part        : part,
            m_UsedNum     : 0
        });
        PartManager storage pm = GetPartManager(lv,part);
        pm.m_IndexList.push(iChip);
    }

    function GetChip(uint32 iChip) internal view returns(Chip storage)
    {
        return g_ChipLib.m_Lib[iChip];
    }

    function GetPartManager(uint8 level, uint iPart) internal view returns(PartManager storage)
    {
        return g_ChipLib.m_PartMap[level][iPart];
    }

    function ChipExists(uint32 iChip) public view returns(bool)
    {
        Chip storage obj = GetChip(iChip);
        return obj.m_Index == iChip;
    }

    function GetChipUsedNum(uint32 iChip) internal view returns(uint)
    {
        Chip storage obj = GetChip(iChip);
        uint[] memory tempList = g_ChipLib.m_TempList[iChip];
        uint num = tempList.length;
        for (uint i=num; i>0; i--)
        {
            if(tempList[i-1]<=now) {
                num -= i;
                break;
            }
        }
        return obj.m_UsedNum + num;
    }

    function CanObtainChip(uint32 iChip) internal view returns(bool)
    {
        Chip storage obj = GetChip(iChip);
        if (obj.m_LimitNum == 0) return true;
        if (GetChipUsedNum(iChip) < obj.m_LimitNum) return true;
        return false;
    }

    function CostChip(uint32 iChip) internal
    {
        BeforeChipCost(iChip);
        Chip storage obj = GetChip(iChip);
        obj.m_UsedNum--;
    }

    function ObtainChip(uint32 iChip) internal
    {
        BeforeChipObtain(iChip);
        Chip storage obj = GetChip(iChip);
        obj.m_UsedNum++;
    }

    function BeforeChipObtain(uint32 iChip) internal
    {
        Chip storage obj = GetChip(iChip);
        if (obj.m_LimitNum == 0) return;
        uint usedNum = GetChipUsedNum(iChip);
        require(obj.m_LimitNum >= usedNum+1);
        if (obj.m_LimitNum == usedNum+1) {
            PartManager storage pm = GetPartManager(obj.m_Level,obj.m_Part);
            if (pm.m_IndexList.remove(iChip)){
                pm.m_UnableList.push(iChip);
            }
        }
    }

    function BeforeChipCost(uint32 iChip) internal
    {
        Chip storage obj = GetChip(iChip);
        if (obj.m_LimitNum == 0) return;
        uint usedNum = GetChipUsedNum(iChip);
        require(obj.m_LimitNum >= usedNum);
        if (obj.m_LimitNum == usedNum) {
            PartManager storage pm = GetPartManager(obj.m_Level,obj.m_Part);
            if (pm.m_UnableList.remove(iChip)) {
                pm.m_IndexList.push(iChip);
            }
        }
    }

    function AddChipTempTime(uint32 iChip, uint expireTime) internal
    {
        uint[] storage list = g_ChipLib.m_TempList[iChip];
        require(list.length==0 || expireTime>=list[list.length-1]);
        BeforeChipObtain(iChip);
        list.push(expireTime);
    }

    function RefreshChipUnableList(uint8 level) internal
    {
        uint partNum = GetPartNum(level);
        for (uint iPart=1; iPart<=partNum; iPart++)
        {
            PartManager storage pm = GetPartManager(level,iPart);
            for (uint i=pm.m_UnableList.length; i>0; i--)
            {
                uint32 iChip = pm.m_UnableList[i-1];
                if (CanObtainChip(iChip)) {
                    pm.m_IndexList.push(iChip);
                    pm.m_UnableList.remove(iChip,i-1);
                }
            }
        }
    }

    function GenChipByWeight(uint random, uint8 level, uint[] extWeight) internal view returns(uint32)
    {
        uint partNum = GetPartNum(level);
        uint allWeight;
        uint[] memory newWeight = new uint[](partNum+1);
        uint[] memory realWeight = new uint[](partNum+1);
        for (uint iPart=1; iPart<=partNum; iPart++)
        {
            PartManager storage pm = GetPartManager(level,iPart);
            uint curWeight = extWeight[iPart-1]+GetPartWeight(level,iPart);
            allWeight += pm.m_IndexList.length*curWeight;
            newWeight[iPart] = allWeight;
            realWeight[iPart] = curWeight;
        }

        uint weight = random % allWeight;
        for (iPart=1; iPart<=partNum; iPart++)
        {
            if (weight >= newWeight[iPart]) continue;
            pm = GetPartManager(level,iPart);
            uint idx = (weight-newWeight[iPart-1])/realWeight[iPart];
            return pm.m_IndexList[idx];
        }
    }

    function GetChipInfo(uint32 iChip) external view returns(uint32, uint8, uint8, uint, uint8, uint)
    {
        Chip storage obj = GetChip(iChip);
        return (obj.m_Index, obj.m_Level, obj.m_LimitNum, GetPartWeight(obj.m_Level,obj.m_Part), obj.m_Part, GetChipUsedNum(iChip));
    }

    function GetExistsChipList() external view returns(uint32[])
    {
        return g_ChipLib.m_List;
    }

}



