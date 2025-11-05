pragma solidity ^0.4.22;


contract ICourt is Ownable {

    function getCaseId(address applicant, address respondent, bytes32 deal, uint256 date, bytes32 title, uint256 amount) 
        public pure returns(bytes32);

    function getCaseStatus(bytes32 caseId) public view returns(uint8);

    function getCaseVerdict(bytes32 caseId) public view returns(bool);
}

library EscrowConfigLib {

    function getPaymentFee(address storageAddress) public view returns (uint8) {
        return EternalStorage(storageAddress).getUint8(keccak256(abi.encodePacked("escrow.config.payment.fee")));
    }

    function setPaymentFee(address storageAddress, uint8 value) public {
        EternalStorage(storageAddress).setUint8(keccak256(abi.encodePacked("escrow.config.payment.fee")), value);
    }
}
