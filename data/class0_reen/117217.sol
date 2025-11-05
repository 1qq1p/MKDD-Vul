pragma solidity 0.4.25;

library SafeMath256 {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function pow(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        if (b == 0) return 1;

        uint256 c = a ** b;
        assert(c / (a ** (b - 1)) == a);
        return c;
    }
}

contract Core {
    function isEggOwner(address, uint256) external view returns (bool);
    function createEgg(address, uint8) external returns (uint256);
    function sendToNest(uint256) external returns (bool, uint256, uint256, address);
    function openEgg(address, uint256, uint256) internal returns (uint256);
    function breed(address, uint256, uint256) external returns (uint256);
    function setDragonRemainingHealthAndMana(uint256, uint32, uint32) external;
    function increaseDragonExperience(uint256, uint256) external;
    function upgradeDragonGenes(uint256, uint16[10]) external;
    function increaseDragonWins(uint256) external;
    function increaseDragonDefeats(uint256) external;
    function setDragonTactics(uint256, uint8, uint8) external;
    function setDragonName(uint256, string) external returns (bytes32);
    function setDragonSpecialPeacefulSkill(uint256, uint8) external;
    function useDragonSpecialPeacefulSkill(address, uint256, uint256) external;
    function updateLeaderboardRewardTime() external;
    function getDragonsFromLeaderboard() external view returns (uint256[10]);
    function getLeaderboardRewards(uint256) external view returns (uint256[10]);
}
