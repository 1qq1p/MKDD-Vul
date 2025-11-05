pragma solidity ^0.4.24;










library PopoDatasets {

  struct Order {
    uint256 pID;
    uint256 createTime;
    uint256 createDayIndex;
    uint256 orderValue;
    uint256 refund;
    uint256 withdrawn;
    bool hasWithdrawn;
  }
  
  struct Player {
    address addr;
    bytes32 name;

    bool inviteEnable;
    uint256 inviterPID;
    uint256 [] inviteePIDs;
    uint256 inviteReward1;
    uint256 inviteReward2;
    uint256 inviteReward3;
    uint256 inviteRewardWithdrawn;

    uint256 [] oIDs;
    uint256 lastOrderDayIndex;
    uint256 dayEthIn;
  }

}
contract InvitePopo is CorePopo {

  using NameFilter for string;
  
  function enableInvite (string _nameString, bytes32 _inviterName)
    isActivated()
    isHuman()
    public
    payable
  {
    require (msg.value == 0.01 ether, "enable invite need 0.01 ether");     

    determinePID();
    determineInviter(addr_pID_[msg.sender], _inviterName);
   
    require (pID_Player_[addr_pID_[msg.sender]].inviteEnable == false, "you can only enable invite once");

    bytes32 _name = _nameString.nameFilter();
    require (name_pID_[_name] == 0, "your name is already registered by others");
    
    pID_Player_[addr_pID_[msg.sender]].name = _name;
    pID_Player_[addr_pID_[msg.sender]].inviteEnable = true;

    name_pID_[_name] = addr_pID_[msg.sender];

    communityPot_ = communityPot_.add(msg.value);

    emit PopoEvents.onEnableInvite
    (
      addr_pID_[msg.sender],
      msg.sender,
      _name,
      now
    );
  }

  function enableInviteOfSU (string _nameString) 
    onlyCEO()
    onlyCommunityLeader()
    isActivated()
    isHuman()
    public
  {
    determinePID();
   
    require (pID_Player_[addr_pID_[msg.sender]].inviteEnable == false, "you can only enable invite once");

    bytes32 _name = _nameString.nameFilter();
    require (name_pID_[_name] == 0, "your name is already registered by others");
    
    name_pID_[_name] = addr_pID_[msg.sender];

    pID_Player_[addr_pID_[msg.sender]].name = _name;
    pID_Player_[addr_pID_[msg.sender]].inviteEnable = true;
  }

  function determineInviter (uint256 _pID, bytes32 _inviterName) 
    internal
  {
    if (pID_Player_[_pID].inviterPID != 0) {
      return;
    }

    uint256 _inviterPID = name_pID_[_inviterName];
    require (_inviterPID != 0, "your inviter name must be registered");
    require (pID_Player_[_inviterPID].inviteEnable == true, "your inviter must enable invite");
    require (_inviterPID != _pID, "you can not invite yourself");

    pID_Player_[_pID].inviterPID = _inviterPID;

    emit PopoEvents.onSetInviter
    (
      _pID,
      msg.sender,
      _inviterPID,
      pID_Player_[_inviterPID].addr,
      _inviterName,
      now
    );
  }

  function distributeInviteReward (uint256 _pID, uint256 _inviteReward1, uint256 _inviteReward2, uint256 _inviteReward3, uint256 _percent) 
    internal
    returns (uint256)
  {
    uint256 inviterPID = pID_Player_[_pID].inviterPID;
    if (pID_Player_[inviterPID].inviteEnable) 
    {
      pID_Player_[inviterPID].inviteReward1 = pID_Player_[inviterPID].inviteReward1.add(_inviteReward1);

      if (inviteePID_inviteReward1_[_pID] == 0) {
        pID_Player_[inviterPID].inviteePIDs.push(_pID);
      }
      inviteePID_inviteReward1_[_pID] = inviteePID_inviteReward1_[_pID].add(_inviteReward1);

      _percent = _percent.sub(5);
    } 
    
    uint256 inviterPID_inviterPID = pID_Player_[inviterPID].inviterPID;
    if (pID_Player_[inviterPID_inviterPID].inviteEnable) 
    {
      pID_Player_[inviterPID_inviterPID].inviteReward2 = pID_Player_[inviterPID_inviterPID].inviteReward2.add(_inviteReward2);

      _percent = _percent.sub(2);
    }

    uint256 inviterPID_inviterPID_inviterPID = pID_Player_[inviterPID_inviterPID].inviterPID;
    if (pID_Player_[inviterPID_inviterPID_inviterPID].inviteEnable) 
    {
      pID_Player_[inviterPID_inviterPID_inviterPID].inviteReward3 = pID_Player_[inviterPID_inviterPID_inviterPID].inviteReward3.add(_inviteReward3);

      _percent = _percent.sub(1);
    } 

    return
    (
      _percent
    );
  }
  
}