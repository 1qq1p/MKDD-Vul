pragma solidity 0.4.15;


contract EuroTokenMigrationTarget is
    MigrationTarget
{
    
    
    

    
    
    function migrateEuroTokenOwner(address owner, uint256 amount)
        public
        onlyMigrationSource();
}





