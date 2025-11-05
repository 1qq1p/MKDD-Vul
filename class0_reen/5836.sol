









	
	
	
pragma solidity ^0.4.19;
contract CryptoMines is Resources {
	mapping(uint256 => address) internal MineOwner; 
	mapping(uint256 => uint8) internal MineLevel; 
	mapping(uint256 => uint256) internal MineCooldown; 
	uint256 public nextMineId = 15;
	uint256 public nextMineEvent = 1;
	
	event MineAffected(uint256 indexed AffectId, uint256 MineId);

	function createNewMine(uint8 _MineLVL) internal {
        MineOwner[nextMineId] = msg.sender;
        MineLevel[nextMineId] = _MineLVL;
        MineCooldown[nextMineId] = now;
		
		nextMineId++;
	}
	
	function StartMiningByIdArray(uint256[] _MineIds) public {
	    uint256 MinesCount = _MineIds.length;
		
		require(MinesCount>0);
		
		for (uint256 key=0; key < MinesCount; key++) {
			if (MineOwner[_MineIds[key]]==msg.sender)
				StartMiningById(_MineIds[key]); 
		}
	}
	
	function StartMiningById(uint256 _MineId) internal {
	    
		uint8 MineLVL=MineLevel[_MineId];
		
		assert (MineLVL>0 && MineOwner[_MineId]==msg.sender);	
		
	    uint256 MiningDays = (now - MineCooldown[_MineId])/86400;
		
		assert (MiningDays>0);

		uint256 newCooldown = MineCooldown[_MineId] + MiningDays*86400;
		
		if (MineLVL==14) {
			
			MineLVL = 13;
			MiningDays = MiningDays*2;
		}
		
		for (uint8 lvl=1; lvl<=MineLVL; lvl++) {
			ResourcesOwner[lvl][msg.sender] +=  (MineLVL-lvl+1)*MiningDays;
		}
	
		MineCooldown[_MineId] = newCooldown;
	}	
	
	function UpMineLVL(uint256 _MineId) public {	
		uint8 MineLVL=MineLevel[_MineId];
		
		require (MineLVL>0 && MineLVL<=13 && MineOwner[_MineId]==msg.sender);	
		
		for (uint8 lvl=1; lvl<=MineLVL; lvl++) {
		    require (ResourcesOwner[lvl][msg.sender] >= (MineLVL-lvl+2)*15);
		}

		for (lvl=1; lvl<=MineLVL; lvl++) {
		    ResourcesOwner[lvl][msg.sender] -= (MineLVL-lvl+2)*15;
			
			if (MineLVL==13 && lvl<=12) 
			    createNewMine(lvl);
		}
		
		MineLevel[_MineId]++;
		
		MineAffected(nextMineEvent,_MineId);
		nextMineEvent++;		
	}
}
