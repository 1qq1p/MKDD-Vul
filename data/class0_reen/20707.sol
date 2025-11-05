pragma solidity ^0.4.17;
contract ISponsoredLeaderboardData is AccessControl {

  
    uint16 public totalLeaderboards;
    
    
    
    uint public contractReservedBalance;
    

    function setMinMaxDays(uint8 _minDays, uint8 _maxDays) external ;
        function openLeaderboard(uint8 numDays, string message) external payable ;
        function closeLeaderboard(uint16 leaderboardId) onlySERAPHIM external;
        
        function setMedalsClaimed(uint16 leaderboardId) onlySERAPHIM external ;
    function withdrawEther() onlyCREATOR external;
  function getTeamFromLeaderboard(uint16 leaderboardId, uint8 rank) public constant returns (uint64 angelId, uint64 petId, uint64 accessoryId) ;
    
    function getLeaderboard(uint16 id) public constant returns (uint startTime, uint endTime, bool isLive, address sponsor, uint prize, uint8 numTeams, string message, bool medalsClaimed);
      function newTeamOnEnd(uint16 leaderboardId, uint64 angelId, uint64 petId, uint64 accessoryId) onlySERAPHIM external;
       function switchRankings (uint16 leaderboardId, uint8 spot,uint64 angel1ID, uint64 pet1ID, uint64 accessory1ID,uint64 angel2ID,uint64 pet2ID,uint64 accessory2ID) onlySERAPHIM external;
       function verifyPosition(uint16 leaderboardId, uint8 spot, uint64 angelID) external constant returns (bool); 
        function angelOnLeaderboards(uint64 angelID) external constant returns (bool);
         function petOnLeaderboards(uint64 petID) external constant returns (bool);
         function accessoryOnLeaderboards(uint64 accessoryID) external constant returns (bool) ;
    function safeMult(uint x, uint y) pure internal returns(uint) ;
     function SafeDiv(uint256 a, uint256 b) internal pure returns (uint256) ;
    function getTotalLeaderboards() public constant returns (uint16);
      
  
        
   
        
        
        
   
      
        
   
}