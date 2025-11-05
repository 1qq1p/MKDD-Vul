pragma solidity 0.4.25;

library SafeMath32 {

    function mul(uint32 a, uint32 b) internal pure returns (uint32) {
        if (a == 0) {
            return 0;
        }
        uint32 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint32 a, uint32 b) internal pure returns (uint32) {
        return a / b;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {
        assert(b <= a);
        return a - b;
    }

    function add(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
        assert(c >= a);
        return c;
    }

    function pow(uint32 a, uint32 b) internal pure returns (uint32) {
        if (a == 0) return 0;
        if (b == 0) return 1;

        uint32 c = a ** b;
        assert(c / (a ** (b - 1)) == a);
        return c;
    }
}

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

contract DragonModel {

    struct HealthAndMana {
        uint256 timestamp; 
        uint32 remainingHealth;
        uint32 remainingMana; 
        uint32 maxHealth;
        uint32 maxMana;
    }

    struct Level {
        uint8 level;
        uint8 experience;
        uint16 dnaPoints;
    }
    
    struct Tactics {
        uint8 melee;
        uint8 attack;
    }

    struct Battles {
        uint16 wins;
        uint16 defeats;
    }

    struct Skills {
        uint32 attack;
        uint32 defense;
        uint32 stamina;
        uint32 speed;
        uint32 intelligence;
    }
    
    struct Dragon {
        uint16 generation;
        uint256[4] genome;
        uint256[2] parents;
        uint8[11] types;
        uint256 birth;
    }

}
