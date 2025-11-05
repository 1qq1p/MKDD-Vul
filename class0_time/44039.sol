pragma solidity ^0.4.24;

















contract Migratable {
  




  event Migrated(string contractName, string migrationId);

  



  mapping (string => mapping (string => bool)) internal migrated;

  


  string constant private INITIALIZED_ID = "initialized";


  




  modifier isInitializer(string contractName, string migrationId) {
    validateMigrationIsPending(contractName, INITIALIZED_ID);
    validateMigrationIsPending(contractName, migrationId);
    _;
    emit Migrated(contractName, migrationId);
    migrated[contractName][migrationId] = true;
    migrated[contractName][INITIALIZED_ID] = true;
  }

  






  modifier isMigration(string contractName, string requiredMigrationId, string newMigrationId) {
    require(isMigrated(contractName, requiredMigrationId), "Prerequisite migration ID has not been run yet");
    validateMigrationIsPending(contractName, newMigrationId);
    _;
    emit Migrated(contractName, newMigrationId);
    migrated[contractName][newMigrationId] = true;
  }

  





  function isMigrated(string contractName, string migrationId) public view returns(bool) {
    return migrated[contractName][migrationId];
  }

  




  function initialize() isInitializer("Migratable", "1.2.1") public {
  }

  




  function validateMigrationIsPending(string contractName, string migrationId) private {
    require(!isMigrated(contractName, migrationId), "Requested target migration ID has already been run");
  }
}







