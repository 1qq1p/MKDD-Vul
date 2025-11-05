pragma solidity ^0.4.16;



contract EtheremonGateway is EtheremonEnum, BasicAccessControl {
    
    function increaseMonsterExp(uint64 _objId, uint32 amount) onlyModerators public;
    function decreaseMonsterExp(uint64 _objId, uint32 amount) onlyModerators public;
    
    
    function isGason(uint64 _objId) constant external returns(bool);
    function getObjBattleInfo(uint64 _objId) constant external returns(uint32 classId, uint32 exp, bool isGason, 
        uint ancestorLength, uint xfactorsLength);
    function getClassPropertySize(uint32 _classId, PropertyType _type) constant external returns(uint);
    function getClassPropertyValue(uint32 _classId, PropertyType _type, uint index) constant external returns(uint32);
}
