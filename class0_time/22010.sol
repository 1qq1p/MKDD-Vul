pragma solidity ^0.4.23;






contract Certificates is Ownable{
    
    struct Certificate {
        string WorkshopName;
        string Date;
        string Location;
    }

    event CertificateCreated(bytes32 certId, string WorkshopName, string Date, string Location);
    
    mapping (bytes32 => Certificate) public issuedCertificates;

    function getCert(string Name, string Surname, string DateOfIssue) public view returns (string WorkshopName, string Date, string Location) {
        return (issuedCertificates[keccak256(abi.encodePacked(Name, Surname, DateOfIssue))].WorkshopName,
                issuedCertificates[keccak256(abi.encodePacked(Name, Surname, DateOfIssue))].Date,
                issuedCertificates[keccak256(abi.encodePacked(Name, Surname, DateOfIssue))].Location);
    }

    function getCertById(bytes32 certId) public view returns (string WorkshopName, string Date, string Location) {
        return (issuedCertificates[certId].WorkshopName,
                issuedCertificates[certId].Date,
                issuedCertificates[certId].Location);
    }
    
    function setCertById(bytes32 certId, string WorkshopName, string Date, string Location) public onlyOwner{
        issuedCertificates[certId] = Certificate(WorkshopName, Date, Location);
        emit CertificateCreated(certId, WorkshopName, Date, Location);
    }
}