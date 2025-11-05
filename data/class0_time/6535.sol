pragma solidity ^0.4.19;




contract BattleBase is Ownable, Pausable {
    event TeamCreated(uint256 indexed teamId, uint256[] fighterIds);
    event TeamDeleted(uint256 indexed teamId, uint256[] fighterIds);
    event BattleResult(address indexed winnerAddress, address indexed loserAddress, uint256[] attackerFighterIds, uint256[] defenderFighterIds, bool attackerWon, uint16 prizeFighterGeneration, uint256 prizeFighterGenes, uint32 attackerXpGained, uint32 defenderXpGained);
    
    struct Team {
        address owner;
        uint256[] fighterIds;
    }

    struct RaceBaseStats {
        uint8 strength;
        uint8 dexterity;
        uint8 vitality;
    }
    
    Team[] public teams;
    
    RaceBaseStats[] public raceBaseStats;
    
    uint256 internal randomCounter = 0;
    
    FighterCoreInterface public fighterCore;
    GeneScienceInterface public geneScience;
    BattleDeciderInterface public battleDecider;
    
    mapping (uint256 => uint256) public fighterIndexToTeam;
    mapping (uint256 => bool) public teamIndexToExist;
    
    
    
    
    uint256[] public deletedTeamIds;
    
    uint256 public maxPerTeam = 5;

    uint8[] public genBaseStats = [
        16, 
        12, 
        10, 
        8, 
        7, 
        6, 
        5, 
        4, 
        3, 
        2, 
        1 
    ];
    
    
    
    
    
    
    
    
    
    modifier onlyTeamOwner(uint256 _teamId) {
        require(teams[_teamId].owner == msg.sender);
        _;
    }

    modifier onlyExistingTeam(uint256 _teamId) {
        require(teamIndexToExist[_teamId] == true);
        _;
    }

    function teamExists(uint256 _teamId) public view returns (bool) {
        return teamIndexToExist[_teamId] == true;
    }

    
    function randMod(uint256 _randCounter, uint _modulus) internal view returns (uint256) { 
        return uint(keccak256(now, msg.sender, _randCounter)) % _modulus;
    }

    function getDeletedTeams() public view returns (uint256[]) {
        
        return deletedTeamIds;
    }

    function getRaceBaseStats(uint256 _id) public view returns (
        uint256 strength,
        uint256 dexterity,
        uint256 vitality
    ) {
        RaceBaseStats storage race = raceBaseStats[_id];
        
        strength = race.strength;
        dexterity = race.dexterity;
        vitality = race.vitality;
    }
}


