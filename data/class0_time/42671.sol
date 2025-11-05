pragma solidity 0.4.25;


contract CoreController {
    function claimEgg(address, uint8) external returns (uint256, uint256, uint256, uint256) {}
    function sendToNest(address, uint256) external returns (bool, uint256, uint256, address) {}
    function breed(address, uint256, uint256) external returns (uint256) {}
    function upgradeDragonGenes(address, uint256, uint16[10]) external {}
    function setDragonTactics(address, uint256, uint8, uint8) external {}
    function setDragonName(address, uint256, string) external returns (bytes32) {}
    function setDragonSpecialPeacefulSkill(address, uint256, uint8) external {}
    function useDragonSpecialPeacefulSkill(address, uint256, uint256) external {}
    function distributeLeaderboardRewards() external returns (uint256[10], address[10]) {}
}








