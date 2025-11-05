







pragma solidity 0.4.25;











library CappedMath {
    uint constant private UINT_MAX = 2**256 - 1;

    


    function addCap(uint _a, uint _b) internal pure returns (uint) {
        uint c = _a + _b;
        return c >= _a ? c : UINT_MAX;
    }

    


    function subCap(uint _a, uint _b) internal pure returns (uint) {
        if (_b > _a)
            return 0;
        else
            return _a - _b;
    }

    


    function mulCap(uint _a, uint _b) internal pure returns (uint) {
        
        
        
        if (_a == 0)
            return 0;

        uint c = _a * _b;
        return c / _a == _b ? c : UINT_MAX;
    }
}








contract Arbitrator {

    enum DisputeStatus {Waiting, Appealable, Solved}

    modifier requireArbitrationFee(bytes _extraData) {
        require(msg.value >= arbitrationCost(_extraData), "Not enough ETH to cover arbitration costs.");
        _;
    }
    modifier requireAppealFee(uint _disputeID, bytes _extraData) {
        require(msg.value >= appealCost(_disputeID, _extraData), "Not enough ETH to cover appeal costs.");
        _;
    }

    



    event DisputeCreation(uint indexed _disputeID, Arbitrable indexed _arbitrable);

    


    event AppealPossible(uint indexed _disputeID, Arbitrable indexed _arbitrable);

    



    event AppealDecision(uint indexed _disputeID, Arbitrable indexed _arbitrable);

    





    function createDispute(uint _choices, bytes _extraData) public requireArbitrationFee(_extraData) payable returns(uint disputeID) {}

    



    function arbitrationCost(bytes _extraData) public view returns(uint fee);

    



    function appeal(uint _disputeID, bytes _extraData) public requireAppealFee(_disputeID,_extraData) payable {
        emit AppealDecision(_disputeID, Arbitrable(msg.sender));
    }

    




    function appealCost(uint _disputeID, bytes _extraData) public view returns(uint fee);

    



    function appealPeriod(uint _disputeID) public view returns(uint start, uint end) {}

    



    function disputeStatus(uint _disputeID) public view returns(DisputeStatus status);

    



    function currentRuling(uint _disputeID) public view returns(uint ruling);
}









interface IArbitrable {
    



    event MetaEvidence(uint indexed _metaEvidenceID, string _evidence);

    





    event Dispute(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _metaEvidenceID, uint _evidenceGroupID);

    





    event Evidence(Arbitrator indexed _arbitrator, uint indexed _evidenceGroupID, address indexed _party, string _evidence);

    




    event Ruling(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _ruling);

    




    function rule(uint _disputeID, uint _ruling) public;
}








