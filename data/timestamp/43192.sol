pragma solidity ^0.4.23;

contract Breeding is Ownership {

    GeneScienceInterface public geneScience;

    function setGeneScienceAddress(address _address) external onlyCEO {
        GeneScienceInterface candidateContract = GeneScienceInterface(_address);

        require(candidateContract.isGeneScience());

        geneScience = candidateContract;
    }


    function _updateCooldown(Clown storage _clown) internal {
        if (_clown.cooldownIndex < 7) {
            _clown.cooldownIndex += 1;
        }
    }


    function giveBirth(uint _matronId, uint _sireId) external onlyCOO returns(uint) {
        Clown storage matron = clowns[_matronId];

        Clown storage sire = clowns[_sireId];

        
        require(sire.sex == 1);
        require(matron.sex == 0);
        require(_matronId != _sireId);

        _updateCooldown(sire);
        _updateCooldown(matron);

        require(matron.birthTime != 0);

        uint16 parentGen = matron.generation;
        if (sire.generation > matron.generation) {
            parentGen = sire.generation;
        }

        uint mGenes = matron.genes;
        uint sGenes = sire.genes;
        uint childGenes = geneScience.mixGenes(mGenes, sGenes, promoTypeNum);
        
        address owner = clownIndexToOwner[_matronId];
        uint clownId = _createClown(_matronId, _sireId, parentGen + 1, childGenes, owner);

        return clownId;
    }
}


